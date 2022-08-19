/**
 * Created by wmccu on 1/15/2021.
 */

@IsTest
private class RoyaltyPaymentBatchableTest {
    @TestSetup
    static void createTestDataRoyaltyPaymentBatchableTest() {
        Id royaltyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royalty').getRecordTypeId();
        Country__c usCountry = new Country__c(
                Name = 'United States',
                country2Letter__c = 'US',
                Region__c = 'North America'
        );
        insert usCountry;
        //setup a reseller with no royalty fields set and test royalty opportunities
        Account accountNoRoyaltySettings = new Account(
                Name = 'Test No Setting Reseller',
                Type = 'Reseller',
                Account_Mgt__c = 'Non Managed Account',
                BillingCountryCode = 'US'
        );
        insert accountNoRoyaltySettings;
        Opportunity royalty1 = new Opportunity(
                Name = 'Test Royalty Request 1',
                AccountId = accountNoRoyaltySettings.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Royalty_Amount__c = 100,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Pending',
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty1;
        Opportunity royalty2 = new Opportunity(
                Name = 'Test Royalty Request 1',
                AccountId = accountNoRoyaltySettings.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Submit_for_Approval__c = true,
                Royalty_Amount__c = 500,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today().toStartOfMonth().addDays(-7),
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty2;
        //setup a quarterly reseller and test royalty opportunities
        Account accountQuarterly = new Account(
                Name = 'Test Quarterly Reseller',
                Type = 'Reseller',
                Account_Mgt__c = 'Non Managed Account',
                BillingCountryCode = 'US',
                Royalty_Processing_Date__c = Date.today().toStartOfMonth().addMonths(-1),
                Royalty_Processing__c = 'Quarterly'
        );
        insert accountQuarterly;
        Set<Integer> royaltyPayMonths = RoyaltyPaymentActions.getQuarterlyPayMonthsFromStartMonth(accountQuarterly.Royalty_Processing_Date__c.month());
        System.debug(royaltyPayMonths);
        Opportunity royalty3 = new Opportunity(
                Name = 'Test Royalty Request 3',
                AccountId = accountQuarterly.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Royalty_Amount__c = 100,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Pending',
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty3;
        Opportunity royalty4 = new Opportunity(
                Name = 'Test Royalty Request 4',
                AccountId = accountQuarterly.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Submit_for_Approval__c = true,
                Royalty_Amount__c = 500,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today().addDays(-45),
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty4;
        //setup a yearly reseller and test royalty opportunities
        Account accountYearly = new Account(
                Name = 'Test Yearly Reseller',
                Type = 'Reseller',
                Account_Mgt__c = 'Non Managed Account',
                BillingCountryCode = 'US',
                Royalty_Processing_Date__c = Date.today().toStartOfMonth().addMonths(-6),
                Royalty_Processing__c = 'Annually'
        );
        insert accountYearly;
        Opportunity royalty5 = new Opportunity(
                Name = 'Test Royalty Request 5',
                AccountId = accountYearly.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Royalty_Amount__c = 100,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Pending',
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty5;
        Opportunity royalty6 = new Opportunity(
                Name = 'Test Royalty Request 6',
                AccountId = accountYearly.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Amount = 100,
                Submit_for_Approval__c = true,
                Royalty_Amount__c = 500,
                Royalty_Expiration_Date__c = Date.today().addDays(30),
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today().addDays(-45),
                Industry_Tag__c = 'Corporate',
                Contract_Required__c = 'No',
                RecordTypeId = royaltyRecordTypeId
        );
        insert royalty6;
    }
    @IsTest
    static void monthlyResellerShouldCreatePayments() {
        List<Opportunity> verifyRequests = [
                SELECT Id, Name, Account.Name, RecordType.Name, Approval_Status__c, Approval_Date__c
                FROM Opportunity
                WHERE Approval_Status__c = 'Approved'
        ];
        System.debug(verifyRequests);
        Date asOfDate = Date.today().addMonths(1);
        Test.startTest();
        RoyaltyPaymentBatchable batchJob = new RoyaltyPaymentBatchable('SELECT AccountId, Account.Royalty_Processing__c, Account.Reseller_Royalty_Start_Date__c FROM Opportunity WHERE Approval_Status__c = \'Approved\' AND Royalty_Payment__c = NULL AND RecordType.Name = \'Royalty\'', asOfDate);
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Royalty_Payment__c> royaltyPayments = [SELECT Id, Reseller__c, Royalty_Amount__c FROM Royalty_Payment__c];
        System.debug(royaltyPayments);
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE Royalty_Payment__c IN :royaltyPayments];
        System.debug(opportunities);
        System.assert(opportunities.size() > 0);
    }
    @IsTest
    static void quarterlyResellerShouldCreatePayments() {
        List<Opportunity> resetApprovedRequests = [
                SELECT Id, Name, Account.Name, RecordType.Name, Approval_Status__c, Approval_Date__c
                FROM Opportunity
                WHERE Approval_Status__c = 'Approved'
                AND Account.Name IN ('Test No Setting Reseller','Test Yearly Reseller')
        ];
        System.debug(resetApprovedRequests);
        for (Opportunity opportunity : resetApprovedRequests) {
            opportunity.Approval_Status__c = 'Pending';
            opportunity.Approval_Date__c = null;
        }
        update resetApprovedRequests;
        Date asOfDate = Date.today().addMonths(2);
        Test.startTest();
        RoyaltyPaymentBatchable batchJob = new RoyaltyPaymentBatchable('SELECT AccountId, Account.Royalty_Processing__c, Account.Reseller_Royalty_Start_Date__c FROM Opportunity WHERE Approval_Status__c = \'Approved\' AND Royalty_Payment__c = NULL AND RecordType.Name = \'Royalty\'', asOfDate);
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Royalty_Payment__c> royaltyPayments = [SELECT Id, Reseller__c, Royalty_Amount__c FROM Royalty_Payment__c];
        System.debug(royaltyPayments);
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE Royalty_Payment__c IN :royaltyPayments];
        System.debug(opportunities);
        System.assert(opportunities.size() > 0);
    }
    @IsTest
    static void yearlyResellerShouldCreatePayments() {
        List<Opportunity> verifyRequests = [
                SELECT Id, Name, Account.Name, RecordType.Name, Approval_Status__c, Approval_Date__c
                FROM Opportunity
                WHERE Approval_Status__c = 'Approved'
        ];
        System.debug(verifyRequests);
        Date asOfDate = Date.today().addMonths(7);
        Test.startTest();
        RoyaltyPaymentBatchable batchJob = new RoyaltyPaymentBatchable('SELECT AccountId, Account.Royalty_Processing__c, Account.Reseller_Royalty_Start_Date__c FROM Opportunity WHERE Approval_Status__c = \'Approved\' AND Royalty_Payment__c = NULL AND RecordType.Name = \'Royalty\'', asOfDate);
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Royalty_Payment__c> royaltyPayments = [SELECT Id, Reseller__c, Royalty_Amount__c FROM Royalty_Payment__c];
        System.debug(royaltyPayments);
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE Royalty_Payment__c IN :royaltyPayments];
        System.debug(opportunities);
        System.assert(opportunities.size() > 0);
    }
    @IsTest
    static void invocableCallShouldRunBatch() {
        List<Opportunity> verifyRequests = [
                SELECT Id, Name, Account.Name, RecordType.Name, Approval_Status__c, Approval_Date__c
                FROM Opportunity
                WHERE Approval_Status__c = 'Approved'
        ];
        System.debug(verifyRequests);
        Test.startTest();
        RoyaltyPaymentBatchable.executeRoyaltyPaymentBatchable();
        Test.stopTest();
    }
    @IsTest
    static void testRoyaltyPaymentBatchableSchedulerMethods() {
        Test.startTest();
        //Remove scheduled job
        RoyaltyPaymentBatchable.removeRoyaltyPaymentBatchable();

        // validate the schedule removed
        List<CronTrigger> remove = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%RoyaltyPaymentBatchable%'];
        System.assertEquals(0, remove.size());

        RoyaltyPaymentBatchable.scheduleRoyaltyPaymentBatchable();
        // validate the schedule added
        List<CronTrigger> job = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%RoyaltyPaymentBatchable%'];
        System.assertEquals(1, job.size());
        Test.stopTest();
    }
}