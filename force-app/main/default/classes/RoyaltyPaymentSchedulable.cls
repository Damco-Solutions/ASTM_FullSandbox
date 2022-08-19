/**
 * Created by johnpernock from OpenGate Consulting on 11/12/19.
 */

global class RoyaltyPaymentSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        RoyaltyPaymentActions.createPaymentsFromRequests();
    }
    global static void SchedulerMethod() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  RoyaltyPaymentSchedulable.SchedulerMethod();
        //
        System.schedule('RoyaltyPayments4Quarters', '0 0 0 1 * ? *', new RoyaltyPaymentSchedulable());
    }
    global static void RemoveSchedulerMethod() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> RoyaltyPaymentSchedulable.RemoveSchedulerMethod();
        //
        for (CronTrigger cronTrigger : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%RoyaltyPayments4Quarters%']) {
            System.abortJob(cronTrigger.Id);
        }
    }
}