/**
 * Created by wmccu on 9/28/2020.
 */

global class AccountSummaryBatchable implements Database.Batchable<SObject>, Schedulable {

    global final String query;
    global final Date currentDate;

    global AccountSummaryBatchable(String q, Date d) {
        query = q;
        currentDate = d;
    }
    @InvocableMethod(Label='Run AccountSummaryBatchable')
    global static void executeAccountSummaryBatchable() {
        AccountSummaryBatchable batchJob = new AccountSummaryBatchable('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity) ORDER BY CreatedDate DESC LIMIT 200', null);
        Database.executeBatch(batchJob);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Date current = currentDate != null ? currentDate : Date.today();
        Integer currentYear = currentDate != null ? currentDate.year() : Date.today().year();
        Integer previousYear = currentYear != null ? currentYear - 1 : Date.today().year() - 1;
        Map<Id, SObject> accountMapIds = new Map<Id, SObject>(scope);
        Set<Id> accountIds = accountMapIds.keySet();
        List<Account> accounts = [
                SELECT Id, Name, Annual_Revenue_Current_Year__c, Annual_Revenue_Previous_Year__c
                FROM Account
                WHERE Id IN:accountIds
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, StageName, CloseDate, AccountId, ContractId
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND AccountId IN :accountIds
        ];
        Map<String, List<SObject>> opportunityMap = ASTMUtilities.convertToListMap(opportunities, 'AccountId');
        Map<String, List<SObject>> contractMap = ASTMUtilities.convertToListMap(getContractsForAccountIds(accountIds), 'AccountId');
        //loop over accounts
        List<Account> accountUpdates = new List<Account>();
        for (Account account : accounts) {
            if (contractMap.containsKey((String) account.Id) && opportunityMap.containsKey((String) account.Id)) {
                Map<String, Contract> contractYearMap = getContractDates(currentYear, contractMap.get(account.Id), current);
                Contract currentYearContract = contractYearMap.get('current');
                System.debug(currentYearContract);
                Contract previousYearContract = contractYearMap.get('previous');
                System.debug(previousYearContract);
                Account updateAccount = new Account(
                        Id = account.Id
                );
                if (currentYearContract != null) {
                    updateAccount.Annual_Revenue_Current_Year__c = getSumAmountFromOpportunities(currentYearContract, opportunityMap.get(account.Id));
                } else {
                    updateAccount.Annual_Revenue_Current_Year__c = 0;
                }
                if (previousYearContract != null) {
                    updateAccount.Annual_Revenue_Previous_Year__c = getSumAmountFromOpportunities(previousYearContract, opportunityMap.get(account.Id));
                } else {
                    updateAccount.Annual_Revenue_Previous_Year__c = 0;
                }
                accountUpdates.add(updateAccount);
            }
        }
        Database.update(accountUpdates, false);
    }

    global void finish(Database.BatchableContext BC) {

    }

    //Schedulable Methods
    global void execute(SchedulableContext context) {
        AccountSummaryBatchable batchJob = new AccountSummaryBatchable('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity)', null);
        Database.executeBatch(batchJob);
    }

    public static void scheduleAccountSummaryBatchable() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  AccountSummaryBatchable.scheduleAccountSummaryBatchable();
        //12AM every day ->  0 0 0 ? * * *
//        String currentYear = String.valueOf(Date.today().year());
        System.schedule('AccountSummaryBatchable', '0 0 0,12 ? * FRI *', new AccountSummaryBatchable('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity)', null));
    }

    public static void removeAccountSummaryBatchable() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> AccountSummaryBatchable.removeAccountSummaryBatchable();
        //
        for (CronTrigger cronTrigger : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'AccountSummaryBatchable']) { //for each record
            System.abortJob(cronTrigger.Id); //abort the job
        }
    }

    public static Map<String, Contract> getContractDates(Integer year, List<Contract> contracts, Date currentDate) {
        //method finds the 'current year' and 'previous year' contracts to use for rolling up the opportunity amounts
        System.debug(currentDate);
        System.debug(year);
        Integer previousYear;
        Map<String, Contract> contractDateMap = new Map<String, Contract>();
        Contract contractForCurrentYear = null;
        Contract contractForPreviousYear = null;
        //loop over contracts and find the most recent, activated contract in the current year
        for (Contract contract : contracts) {
            //only consider activated contracts with an end date
            if (contract.EndDate != null) {
                //end date is in the same year as our current year
                //end date is still less than today
                //and the contract is activated
                if (contract.StartDate.year() == year
                        && contract.EndDate >= currentDate
                        && contract.Status == 'Activated') {
                    if (contractForCurrentYear == null) {
                        contractForCurrentYear = contract;
                    } else {
                        if (contract.EndDate > contractForCurrentYear.EndDate) {
                            contractForCurrentYear = contract;
                        }
                    }
                }
            }
        }
        //no current year contract, then search for the most recent previous year contract
        if (contractForCurrentYear == null) {
            for (Contract contract : contracts) {
                if (contract.EndDate != null) {
                    if (contract.EndDate.year() == year) {
                        if (contractForPreviousYear == null) {
                            contractForPreviousYear = contract;
                        } else {
                            if (contract.EndDate > contractForPreviousYear.EndDate) {
                                contractForPreviousYear = contract;
                            }
                        }
                    }
                }
            }
        }
        //if we did not set the previous year, find the most recent contract that has
        //
        if (contractForPreviousYear == null) {
            if (contractForPreviousYear == null) {
                previousYear = year - 1;
            } else {
                previousYear = contractForCurrentYear.EndDate != null ? contractForCurrentYear.EndDate.year() - 1 : year - 1 ;
            }
//            System.debug(previousYear);
            for (Contract contract : contracts) {
                if (contract.StartDate != null) {
                    if (contract.StartDate.year() == previousYear
                            && contract.EndDate < currentDate
                            && contract.Status == 'Subscription Completed') {
                        if (contractForPreviousYear == null) {
                            contractForPreviousYear = contract;
                        } else {
                            if (contract.EndDate > contractForPreviousYear.EndDate) {
                                contractForPreviousYear = contract;
                            }
                        }
                    }
                }
            }
        }
        contractDateMap.put('current', contractForCurrentYear);
        contractDateMap.put('previous', contractForPreviousYear);
        System.debug(contractDateMap);
        return contractDateMap;
    }
    @TestVisible
    private static Decimal getSumAmountFromOpportunities(Contract contract, List<Opportunity> opportunities) {
        Decimal sumAmount = 0;
        if (opportunities == null) {
            return sumAmount;
        }
        for (Opportunity opportunity : opportunities) {
            if (opportunity.ContractId == contract.Id) {
                sumAmount += opportunity.Amount != null ? opportunity.Amount : 0;
            }
        }
        return sumAmount;
    }

    public static List<Contract> getContractsForAccountIds(Set<Id> accountIds) {
        List<Contract> contracts = [
                SELECT Id, Status, StartDate, EndDate, Related_Opportunity__c, AccountId, ActivatedDate
                FROM Contract
                WHERE AccountId IN :accountIds
                ORDER BY EndDate DESC
        ];
        return contracts;
    }
}