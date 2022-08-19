/**
 * Created by wmccu on 11/12/2020.
 */

global class ContractBatch implements Database.Batchable<SObject>, Schedulable {

    global final String query;

    global ContractBatch(String q) {
        query = q;
    }
    @InvocableMethod(Label='Run ContractBatch')
    global static void executeContractBatch() {
        ContractBatch batchJob = new ContractBatch('SELECT Id, StartDate, EndDate, Status FROM Contract WHERE Status !=\'Subscription Completed\'');
        Database.executeBatch(batchJob);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Contract> contracts = new List<Contract>();
        for (SObject sobj : scope) {
            Contract currentContract = (Contract) sobj;
            if (currentContract.StartDate <= Date.today() && currentContract.EndDate > Date.today()) {
                //activate the contract
                contracts.add(new Contract(
                        Id = currentContract.Id,
                        Status = 'Activated'
                ));
            }
            System.debug('Today -> ' + Date.today());
            System.debug('EndDate  ' + currentContract.EndDate);
            if (currentContract.EndDate <= Date.today()) {
                //de-activate the contract
                contracts.add(new Contract(
                        Id = currentContract.Id,
                        Status = 'Subscription Completed'
                ));
            }
        }
        if (contracts.size() > 0) {
            Database.update(contracts, false);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    //Schedulable Methods
    global void execute(SchedulableContext context) {
        ContractBatch batchJob = new ContractBatch('SELECT Id, StartDate, EndDate, Status FROM Contract WHERE Status !=\'Subscription Completed\'');
        Database.executeBatch(batchJob);
    }

    public static void scheduleContractBatch() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  ContractBatch.scheduleContractBatch();
        //12AM every day ->  0 0 0 ? * * *
        System.schedule('ContractBatch', '0 0 0,12 ? * FRI *', new ContractBatch('SELECT Id, StartDate, EndDate, Status FROM Contract WHERE Status !=\'Subscription Completed\''));
    }

    public static void removeContractBatch() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> ContractBatch.removeContractBatch();
        //
        for (CronTrigger cronTrigger : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'ContractBatch']) { //for each record
            System.abortJob(cronTrigger.Id); //abort the job
        }
    }
}