/**
 * Created by wmccu on 9/28/2021.
 */

global class GrowthLogicBatch implements Database.Batchable<SObject>, Schedulable {
    global final String query;

    global GrowthLogicBatch(String q) {
        query = String.isEmpty(q) ? getGrowthLogicBatchQuery() : q;
    }
    @InvocableMethod(Label='Run GrowthLogicBatch')
    global static void executeGrowthLogicBatch() {
        GrowthLogicBatch batchJob = new GrowthLogicBatch('');
        Database.executeBatch(batchJob);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (SObject sobj : scope) {
            opportunities.add(
                    new Opportunity(
                            Id = sobj.Id,
                            Recalculate_Growth__c = true
                    )
            );
        }
        update opportunities;
    }

    global void finish(Database.BatchableContext BC) {

    }

    //Schedulable Methods
    global void execute(SchedulableContext context) {
        GrowthLogicBatch batchJob = new GrowthLogicBatch('');
        Database.executeBatch(batchJob);
    }

    public static void scheduleGrowthLogicBatch() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  GrowthLogicBatch.scheduleGrowthLogicBatch();
        //'0 0 0 1 1/3 ? *' - 1st of every 3 months beginning January
        System.schedule('GrowthLogicBatch', '0 0 0 1 1/3 ? *', new GrowthLogicBatch(''));
    }

    public static void removeGrowthLogicBatch() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> GrowthLogicBatch.removeGrowthLogicBatch();
        //
        for (CronTrigger cronTrigger : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'GrowthLogicBatch']) { //for each record
            System.abortJob(cronTrigger.Id); //abort the job
        }
    }

    private static String getGrowthLogicBatchQuery() {
        return 'SELECT Id, Recalculate_Growth__c FROM Opportunity WHERE CloseDate = LAST_QUARTER AND StageName = \'Closed Won\'';
    }
}