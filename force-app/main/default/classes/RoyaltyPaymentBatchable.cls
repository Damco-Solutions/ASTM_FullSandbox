/**
 * Created by wmccu on 1/14/2021.
 */

global class RoyaltyPaymentBatchable implements Database.Batchable<SObject>, Schedulable {

    global final String query;
    global final Date asOfDate;

    global RoyaltyPaymentBatchable(String q, Date d) {
        query = q;
        asOfDate = d;
    }
    @InvocableMethod(Label='Run RoyaltyPaymentBatchable')
    global static void executeRoyaltyPaymentBatchable() {
        RoyaltyPaymentBatchable batchJob = new RoyaltyPaymentBatchable(getRoyaltyPaymentQuery(), Date.today());
        Database.executeBatch(batchJob);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (SObject sobj : scope) {
            Opportunity currentOpportunity = (Opportunity) sobj;
            if (!accountIds.contains(currentOpportunity.AccountId)) {
                accountIds.add(currentOpportunity.AccountId);
            }
        }
        RoyaltyPaymentActions.createPaymentsForResellers(accountIds, asOfDate);
    }

    global void finish(Database.BatchableContext BC) {

    }

    //Schedulable Methods
    global void execute(SchedulableContext context) {
        RoyaltyPaymentBatchable batchJob = new RoyaltyPaymentBatchable(getRoyaltyPaymentQuery(), Date.today());
        Database.executeBatch(batchJob);
    }

    public static void scheduleRoyaltyPaymentBatchable() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  RoyaltyPaymentBatchable.scheduleRoyaltyPaymentBatchable();
        //'0 0 2 1 * ? *' - 2 am on the 1st of every month
        System.schedule('RoyaltyPaymentBatchable', '0 0 2 1 * ? *', new RoyaltyPaymentBatchable(getRoyaltyPaymentQuery(), Date.today()));
    }

    public static void removeRoyaltyPaymentBatchable() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> RoyaltyPaymentBatchable.removeRoyaltyPaymentBatchable();
        //
        for (CronTrigger cronTrigger : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'RoyaltyPaymentBatchable']) { //for each record
            System.abortJob(cronTrigger.Id); //abort the job
        }
    }

    private static String getRoyaltyPaymentQuery() {
        return 'SELECT AccountId, Account.Royalty_Processing__c, Account.Reseller_Royalty_Start_Date__c FROM Opportunity WHERE Approval_Status__c = \'Approved\' AND Royalty_Payment__c = NULL AND RecordType.Name = \'Royalty\' AND Approval_Date__c != NULL AND Approval_Date__c > 2020-12-31';
    }
}