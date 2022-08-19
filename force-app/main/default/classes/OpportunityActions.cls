/**
 * Created by wmccu on 9/25/2020.
 */

public without sharing class OpportunityActions {
    public static void setOpportunityValuesBeforeInsert(List<Opportunity> opportunities) {
        //assumes before trigger context
        String astmCompassPriceBookId = Label.Pricebook_Id_ASTMCOMPASS;
        String astmAenorPriceBookId = Label.Pricebook_Id_AENOR;
        String whiteLabelRecordTypeId = Label.astmWhiteLabelRT;
        String royaltyRecordTypeId = Label.astmRoyaltyRT;
        Set<Id> accountIds = getAccountIdsFromOpportunities(opportunities);
        Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, OwnerId, Owner.Email
                FROM Account
                WHERE Id IN :accountIds
        ]);
        for (Opportunity opportunity : opportunities) {
            //set price book for 2 record types
            if (opportunity.RecordTypeId == (Id) whiteLabelRecordTypeId) {
                opportunity.Pricebook2Id = (Id) astmAenorPriceBookId;
            } else if (opportunity.RecordTypeId == (Id) royaltyRecordTypeId) {
                opportunity.Pricebook2Id = (Id) astmCompassPriceBookId;
            }
            //set Approval Date - assumes that we have checked that the Approval Status field has changed
            if (opportunity.Approval_Status__c == 'Approved') {
                opportunity.Approval_Date__c = Date.today();
            }
            //set account owner email field from Owner.Email
            opportunity.Account_Owner_Email__c = accountMap?.get(opportunity.AccountId)?.Owner.Email;
        }
    }
    public static void setPriceBookBeforeUpdate(List<Opportunity> opportunities) {
        //assumes before trigger context
        String astmCompassPriceBookId = Label.Pricebook_Id_ASTMCOMPASS;
        String astmAenorPriceBookId = Label.Pricebook_Id_AENOR;
        String whiteLabelRecordTypeId = Label.astmWhiteLabelRT;
        String royaltyRecordTypeId = Label.astmRoyaltyRT;
        for (Opportunity opportunity : opportunities) {
            //set price book for 2 record types
            if (opportunity.RecordTypeId == (Id) whiteLabelRecordTypeId) {
                opportunity.Pricebook2Id = (Id) astmAenorPriceBookId;
            } else if (opportunity.RecordTypeId == (Id) royaltyRecordTypeId) {
                opportunity.Pricebook2Id = (Id) astmCompassPriceBookId;
            }
        }
    }
    public static void setApprovalDateBeforeUpdate(List<Opportunity> opportunities) {
        //assumes before trigger context
        for (Opportunity opportunity : opportunities) {
            //set Approval Date - assumes that we have checked that the Approval Status field has changed
            if (opportunity.Approval_Status__c == 'Approved') {
                opportunity.Approval_Date__c = Date.today();
            }
        }
    }
    public static void addContractsForNewOpportunities(List<Opportunity> opportunities) {
        Map<Id, Opportunity> opportunityMap
                = new Map<Id, Opportunity>([
                        SELECT Id, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
                                Account.BillingPostalCode, Account.BillingCountryCode
                        FROM Opportunity
                        WHERE Id IN :opportunities
                ]);
        List<Contract> contractsToCreate = new List<Contract>();
        for (Opportunity opportunity : opportunities) {
            Opportunity queryOpp = opportunityMap.get(opportunity.Id);
            Contract newContract = new Contract();
            newContract.Related_Opportunity__c = opportunity.Id;
            newContract.AccountId = opportunity.AccountId;
            newContract.BillingStreet = queryOpp.Account.BillingStreet;
            newContract.BillingCity = queryOpp.Account.BillingCity;
            newContract.BillingCountryCode = queryOpp.Account.BillingCountryCode;
            newContract.BillingStateCode = queryOpp.Account.BillingStateCode;
            newContract.BillingPostalCode = queryOpp.Account.BillingPostalCode;
            newContract.Contract_Renewal_Amount__c = opportunity.Amount == null ? 0 : opportunity.Amount;
            newContract.StartDate = opportunity.CloseDate;
            newContract.ContractTerm = 12;
            contractsToCreate.add(newContract);
        }
        if (contractsToCreate.size() > 0) {
            insert contractsToCreate;
        }
        setContractIdOnOpportunities(contractsToCreate);
    }
    @Future
    public static void addContractsForUpdatedOpportunitiesFuture(Set<Id> oppIds) {
        addContractsForUpdatedOpportunities(oppIds);
    }
    public static void addContractsForUpdatedOpportunities(Set<Id> opportunityIds) {
        Map<Id, Opportunity> opportunityMap
                = new Map<Id, Opportunity>([
                        SELECT Id, AccountId, Amount, CloseDate, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
                                Account.BillingPostalCode, Account.BillingCountryCode, (SELECT Product2.Name, Product2Id FROM OpportunityLineItems)
                        FROM Opportunity
                        WHERE Id IN :opportunityIds
                ]);
        List<Contract> contractsToCreate = new List<Contract>();
        for (Id id : opportunityMap.keySet()) {
            Opportunity queryOpp = opportunityMap.get(id);
            Contract newContract = new Contract();
            if (queryOpp.OpportunityLineItems != null) {
                newContract.Products__c = getProductsString(queryOpp.OpportunityLineItems);
            }
            newContract.Related_Opportunity__c = queryOpp.Id;
            newContract.AccountId = queryOpp.AccountId;
            newContract.BillingStreet = queryOpp.Account.BillingStreet;
            newContract.BillingCity = queryOpp.Account.BillingCity;
            newContract.BillingCountryCode = queryOpp.Account.BillingCountryCode;
            newContract.BillingStateCode = queryOpp.Account.BillingStateCode;
            newContract.BillingPostalCode = queryOpp.Account.BillingPostalCode;
            newContract.Contract_Renewal_Amount__c = queryOpp.Amount == null ? 0 : queryOpp.Amount;
            newContract.StartDate = queryOpp.CloseDate;
            newContract.ContractTerm = 12;
            contractsToCreate.add(newContract);
        }
        if (contractsToCreate.size() > 0) {
            insert contractsToCreate;
        }
        setContractIdOnOpportunities(contractsToCreate);
    }
    public static void linkContractForChangeOfScopeOpportunities(List<Opportunity> opportunities) {
        //assumes before context
        Set<Id> renewalOpportunityIds = ASTMUtilities.getSetIdFromList(opportunities, 'Original_Opportunity__c');
        Map<Id, Opportunity> renewalOpportunityMap = new Map<Id, Opportunity>([
                SELECT Id, Name, ContractId, (SELECT Id FROM Contracts__r ORDER BY CreatedDate DESC LIMIT 1)
                FROM Opportunity
                WHERE Id IN :renewalOpportunityIds
        ]);
        for (Opportunity opportunity : opportunities) {
            if (renewalOpportunityMap.containsKey(opportunity.Original_Opportunity__c)) {
                Opportunity renewalOpportunity = renewalOpportunityMap.get(opportunity.Original_Opportunity__c);
                if (renewalOpportunity.ContractId != null) {
                    //use contract id from renewal opportunity
                    opportunity.ContractId = renewalOpportunity.ContractId;
                } else {
                    //check the related contracts to the renewal opportunity
                    if (renewalOpportunity.Contracts__r != null) {
                        opportunity.ContractId = renewalOpportunity.Contracts__r[0].Id;
                    }
                }
            }
        }
    }
    public static void validateNewBusiness(List<Opportunity> opportunities, Map<Id, Account> accountMap) {
        //assumes before trigger context
        Boolean isEnabled = FeatureManagement.checkPermission('Can_Override_New_Business_Validation');
        Date currentDate = Date.today();
        Integer currentYear = currentDate.year();
        Map<String, List<SObject>> contractMap = ASTMUtilities.convertToListMap(AccountSummaryBatchable.getContractsForAccountIds(accountMap.keySet()), 'AccountId');
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Type == 'New Business' && accountMap.get(opportunity.AccountId).Account_Mgt__c == 'Non Managed Account') {
                if (contractMap.containsKey(opportunity.AccountId)) {
                    Map<String, Contract> contractYearMap = AccountSummaryBatchable.getContractDates(currentYear, contractMap.get(opportunity.AccountId), currentDate);
                    if (contractYearMap.containsKey('current') || contractYearMap.containsKey('previous')) {
                        Contract currentContract = contractYearMap.get('current');
                        if (currentContract == null) {
                            currentContract = contractYearMap.get('previous');
                        }
                        System.debug(currentContract);
                        if (currentContract != null) {
                            Date comparisonDate = currentContract.EndDate.addMonths(3);
                            if (opportunity.CloseDate < comparisonDate && !isEnabled) {
                                opportunity.addError('A Non Managed Account cannot have a New Business Opportunity' +
                                        ' unless the last Contract\'s End Date is more than 3 months ago. ' +
                                        'The Opportunity Close Date is ' + opportunity.CloseDate + '. The ' +
                                        'Contract End Date is ' + currentContract.EndDate);
                            }
                        }
                    }
                }
            }
        }
    }
    public static void setAmountAsGrowth(List<Opportunity> opportunities) {
        //assumes before system context
        for (Opportunity opportunity : opportunities) {
            opportunity.Growth__c = opportunity.Amount == null ? 0 : opportunity.Amount;
        }
    }
    public static void setZeroAsGrowth(List<Opportunity> opportunities) {
        //assumes before system context
        for (Opportunity opportunity : opportunities) {
            opportunity.Growth__c = 0;
        }
    }
    public static void calculateGrowth(List<Opportunity> opportunities) {
        //assumes before insert system context
        //get account ids from opportunities
        Set<Id> accountIds = getAccountIdsFromOpportunities(opportunities);
        Map<Id, Account> accountMap = new Map<Id, Account> ([SELECT Id, Name, Annual_Revenue_Current_Year__c, Annual_Revenue_Previous_Year__c FROM Account WHERE Id IN :accountIds]);
        for (Opportunity opportunity : opportunities) {
            Decimal accountThisYear = accountMap.containsKey(opportunity.AccountId) ? accountMap.get(opportunity.AccountId).Annual_Revenue_Current_Year__c : 0;
            Decimal accountLastYear = accountMap.containsKey(opportunity.AccountId) ? accountMap.get(opportunity.AccountId).Annual_Revenue_Previous_Year__c : 0;
            Decimal amountToStart = opportunity.Amount != null ? opportunity.Amount : 0;
            if (opportunity.StageName == 'Closed Won' && accountThisYear <> 0) {
                amountToStart = 0;
            }
            opportunity.Growth__c = amountToStart + (accountThisYear - accountLastYear);
        }
    }
    public static void resetOpportunityFields(List<Opportunity> opportunities) {
        //assumes before system context
        for (Opportunity opportunity : opportunities) {
            opportunity.Recalculate_Growth__c = false;
        }
    }
    public static void activateRelatedContract(Set<Id> opportunityIds) {
        List<Contract> contracts = [SELECT Id, Status FROM Contract WHERE Related_Opportunity__c IN :opportunityIds];
        for (Contract contract : contracts) {
            contract.Status = 'Activated';
        }
        update contracts;
    }
    private static String getProductsString(List<OpportunityLineItem> opportunityLineItems) {
        String buildProducts = '';
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            buildProducts = buildProducts + ',' + opportunityLineItem.Product2.Name;
        }
        return buildProducts;
    }
    private static Set<Id> getAccountIdsFromOpportunities(List<Opportunity> opportunities) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (!accountIds.contains(opportunity.AccountId)) {
                accountIds.add(opportunity.AccountId);
            }
        }
        return accountIds;
    }
    public static void setContractIdOnOpportunities(List<Contract> contracts) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Contract contract : contracts) {
            opportunities.add(
                    new Opportunity(
                            Id = contract.Related_Opportunity__c,
                            ContractId = contract.Id
                    )
            );
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update opportunities;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
}