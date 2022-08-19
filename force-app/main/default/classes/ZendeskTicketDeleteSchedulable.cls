/**
 * Created by johnpernock from OpenGate Consulting on 9/28/18.
 */

global without sharing class ZendeskTicketDeleteSchedulable implements Schedulable{
    global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        ZendeskTicketDelete ticketDeleteManagement = new ZendeskTicketDelete ();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(ticketDeleteManagement);
    }

    global static void SchedulerMethod() {
        //Usage:  open a Apex Execute Anonymous window
        //enter->  ZendeskTicketDeleteSchedulable.SchedulerMethod();
        //
        System.schedule('ZendeskTicketDeleteSchedulable','0 0 0 * * ?', new ZendeskTicketDeleteSchedulable());
    }

    global static void RemoveSchedulerMethod() {
        //Usage:  open a Apex Execute Anonymous window
        //enter -> ZendeskTicketDeleteSchedulable.RemoveFaxSchedulerMethod();
        //
        for (CronTrigger t : [select Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name like '%ZendeskTicketDeleteSchedulable%']) {
            System.abortJob(t.Id);
        }
    }
}