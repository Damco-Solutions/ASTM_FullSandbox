trigger NewContractFromOpp on Opportunity (after delete) {
    //TODO Delete this trigger

//    Contract newContract = new Contract();
//    List<Contract> contractsToCreate = new List<Contract>();
//
//    Map<Id, Opportunity> acctOppsMap
//            = new Map<Id, Opportunity>([
//                    SELECT Id, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
//                            Account.BillingPostalCode, Account.BillingCountryCode, (SELECT Product2.Name, Product2Id, OpportunityId FROM OpportunityLineItems)
//                    FROM Opportunity
//                    WHERE Id IN :Trigger.new
//            ]);
//    for (Opportunity o : Trigger.new) {
//
//        Opportunity queryOpp = acctOppsMap.get(o.Id);
//
//        if (Trigger.isUpdate) {
//            Opportunity beforeUpdate = System.Trigger.oldMap.get(o.Id);
//
//            if (o.Contract_Required__c != beforeUpdate.Contract_Required__c) {
//                if (o.Contract_Required__c == 'Yes') {
//
//                    List <OpportunityLineItem> OpportunityProducts = [SELECT Product2.Name, Product2Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
//                    String buildProducts = '';
//                    for (OpportunityLineItem opportunityLineItem : OpportunityProducts) {
//                        buildProducts = buildProducts + ',' + opportunityLineItem.Product2.Name;
//                    }
//
//                    newContract.Products__c = buildProducts;
//                    newContract.Related_Opportunity__c = o.Id;
//                    newContract.AccountId = o.AccountId;
//                    newContract.BillingStreet = queryOpp.Account.BillingStreet;
//                    newContract.BillingCity = queryOpp.Account.BillingCity;
//                    newContract.BillingCountryCode = queryOpp.Account.BillingCountryCode;
//                    newContract.BillingStateCode = queryOpp.Account.BillingStateCode;
//                    newContract.BillingPostalCode = queryOpp.Account.BillingPostalCode;
//                    newContract.Contract_Renewal_Amount__c = o.Amount == null ? 0 : o.Amount;
//                    newContract.StartDate = o.CloseDate;
//                    newContract.ContractTerm = 12;
//                    contractsToCreate.add(newContract);
//                }
//            }
//        }
//        if (Trigger.isInsert) {
//            if (o.Contract_Required__c == 'Yes') {
//                newContract.Related_Opportunity__c = o.Id;
//                newContract.AccountId = o.AccountId;
//                newContract.BillingStreet = queryOpp.Account.BillingStreet;
//                newContract.BillingCity = queryOpp.Account.BillingCity;
//                newContract.BillingCountryCode = queryOpp.Account.BillingCountryCode;
//                newContract.BillingStateCode = queryOpp.Account.BillingStateCode;
//                newContract.BillingPostalCode = queryOpp.Account.BillingPostalCode;
//                newContract.Contract_Renewal_Amount__c = o.Amount == null ? 0 : o.Amount;
//                newContract.StartDate = o.CloseDate;
//                newContract.ContractTerm = 12;
//                contractsToCreate.add(newContract);
//            }
//        }
//    }
//    if (contractsToCreate.size() > 0) {
//        insert contractsToCreate;
//    }
}