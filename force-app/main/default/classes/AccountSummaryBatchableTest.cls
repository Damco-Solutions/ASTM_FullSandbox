/**
 * Created by wmccu on 9/30/2020.
 */

@IsTest
private class AccountSummaryBatchableTest {
    @TestSetup
    static void setupAccountSummaryBatchableTestData() {
        Id ihsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IHS Accounts').getRecordTypeId();
        Account testAccount = new Account(
                Name = 'Test Account',
                BillingCountryCode = 'US',
                Account_Mgt__c = 'Managed Account',
                RecordTypeId = ihsRecordTypeId
        );
        insert testAccount;
    }
    @IsTest
    static void invocableBatchProcessShouldUpdateAccountRevenue() {
        Account beforeAccount = [
                SELECT Id, Annual_Revenue_Previous_Year__c, Annual_Revenue_Current_Year__c
                FROM Account
                WHERE Name = 'Test Account'
        ];
        System.debug(beforeAccount);
        Opportunity lastYear = new Opportunity(
                Name = 'Test Main Last Year',
                Industry_Tag__c = 'Academic',
                AccountId = beforeAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today().addYears(-2),
                Amount = 1000,
                Contract_Required__c = 'Yes'
        );
        insert lastYear;
        Opportunity thisYear = new Opportunity(
                Name = 'Test Main This Year',
                Industry_Tag__c = 'Academic',
                AccountId = beforeAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today().addYears(-1),
                Amount = 1000,
                Contract_Required__c = 'Yes'
        );
        insert thisYear;
        Test.startTest();
        List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, StageName
                FROM Opportunity
                WHERE AccountId = :beforeAccount.Id
        ];
        System.debug(opportunities);
        List<Contract> contracts = [
                SELECT Id, StartDate, EndDate, Related_Opportunity__c, AccountId
                FROM Contract
                WHERE AccountId = :beforeAccount.Id
        ];
        System.debug(contracts);
        AccountSummaryBatchable.executeAccountSummaryBatchable();
        Test.stopTest();
        Account afterAccount = [
                SELECT Id, Annual_Revenue_Previous_Year__c, Annual_Revenue_Current_Year__c
                FROM Account
                WHERE Name = 'Test Account'
        ];
        System.debug(afterAccount);
    }
    @IsTest
    static void scheduledHelperClassShouldAddSchedule() {
        AccountSummaryBatchable.removeAccountSummaryBatchable();
        Test.startTest();
        AccountSummaryBatchable.scheduleAccountSummaryBatchable();
        Test.stopTest();
    }
    @IsTest
    static void sequentialDatesShouldReturnCurrentAndPreviousContracts() {
        Date currentDate = Date.today();
        Integer year = currentDate.year();
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-1),
                EndDate = Date.today()
        );
        contracts.add(contract1);
        Contract contract2 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-2),
                EndDate = Date.today().addYears(-1)
        );
        contracts.add(contract2);
        Contract contract3 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-3),
                EndDate = Date.today().addYears(-2)
        );
        contracts.add(contract3);
        System.debug(contracts);
        Test.startTest();
        Map<String, Contract> contractMap = AccountSummaryBatchable.getContractDates(year, contracts, currentDate);
        System.debug(contractMap);
        Test.stopTest();
    }
    @IsTest
    static void overlappingDatesShouldReturnCurrentAndPreviousContracts() {
        Date currentDate = Date.today();
        Integer year = currentDate.year();
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-1),
                EndDate = Date.today()
        );
        contracts.add(contract1);
        Contract contract2 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-1).addMonths(-2),
                EndDate = Date.today().addMonths(-2)
        );
        contracts.add(contract2);
        Contract contract3 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-2),
                EndDate = Date.today().addYears(-1)
        );
        contracts.add(contract3);
        System.debug(contracts);
        Test.startTest();
        Map<String, Contract> contractMap = AccountSummaryBatchable.getContractDates(year, contracts, currentDate);
        System.debug(contractMap);
        Test.stopTest();
    }
    @IsTest
    static void multipleDatesPreviousYearShouldReturnCurrentContracts() {
        Date currentDate = Date.today();
        Integer year = currentDate.year();
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-2),
                EndDate = Date.today().addYears(-1)
        );
        contracts.add(contract1);
        Contract contract2 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-3).addMonths(-2),
                EndDate = Date.today().addYears(-2)
        );
        contracts.add(contract2);
        Contract contract3 = new Contract(
                AccountId = testAccount.Id,
                StartDate = Date.today().addYears(-4).addMonths(-2),
                EndDate = Date.today().addYears(-3)
        );
        contracts.add(contract3);
        System.debug(contracts);
        Test.startTest();
        Map<String, Contract> contractMap = AccountSummaryBatchable.getContractDates(year, contracts, currentDate);
        System.debug(contractMap);
        Test.stopTest();
    }
}