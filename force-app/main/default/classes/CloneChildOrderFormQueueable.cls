/**
 * Created by johnpernock from OpenGate Consulting on 2019-04-11.
 */

public without sharing class CloneChildOrderFormQueueable implements Queueable, Database.AllowsCallouts{
    Set<Id> recordids;
    public CloneChildOrderFormQueueable(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {
        for (Id oppId : recordids){
            Attachment att = new Attachment(Name = 'orderform.xls');
            PageReference Order_page = new PageReference('/apex/OrderFormPage_V2');
            Order_page.getParameters().put('id',oppId);
            Blob content;
            if (Test.isRunningTest()){ content=Blob.valueOf('UNIT.TEST');} else { content= Order_page.getContent();}
            att.Body = content;
            att.ParentId = oppId;
            att.ContentType = 'application/xls';
            insert att;
        }
    }
}