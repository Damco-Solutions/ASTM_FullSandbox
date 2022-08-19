/**
 * Created by William McCullough from OpenGate Consulting on 3/2/2020.
 */

@IsTest
private class RoyaltyPaymentTest {
    @IsTest
    static void testRoyaltyPaymentSchedulerMethods() {
        Test.startTest();
        //Remove scheduled job
        RoyaltyPaymentSchedulable.RemoveSchedulerMethod();

        // validate the schedule removed
        List<CronTrigger> remove = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%RoyaltyPayments4Quarters%'];
        System.assertEquals(0, remove.size());

        RoyaltyPaymentSchedulable.SchedulerMethod();
        // validate the schedule added
        List<CronTrigger> job = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%RoyaltyPayments4Quarters%'];
        System.assertEquals(1, job.size());
        Test.stopTest();
    }
    @IsTest
    static void testRoyaltyPaymentCreation() {
        Account ca = new Account(Name = 'testaccount', Oracle_Account_Number__c = '111222333', BillingCountryCode = 'US');
        insert ca;
        Royalty_Request__c royaltyRequest1 = new Royalty_Request__c(
                Account__c = ca.Id,
                Royalty_Amount__c = 150,
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today(),
                Payment_Frequency__c = 'Annually',
                Payment_Date__c = Date.today()
        );
        insert royaltyRequest1;
        Royalty_Request__c royaltyRequest2 = new Royalty_Request__c(
                Account__c = ca.Id,
                Royalty_Amount__c = 350,
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today(),
                Payment_Frequency__c = 'Quarterly',
                Payment_Date__c = Date.today()
        );
        insert royaltyRequest2;
        Royalty_Request__c royaltyRequest3 = new Royalty_Request__c(
                Account__c = ca.Id,
                Royalty_Amount__c = 250,
                Approval_Status__c = 'Approved',
                Approval_Date__c = Date.today(),
                Payment_Frequency__c = 'Monthly',
                Payment_Date__c = Date.today()
        );
        insert royaltyRequest3;
        Test.startTest();
        RoyaltyPaymentActions.createPaymentsFromRequests();
        Test.stopTest();
    }
}