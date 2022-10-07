@isTest
public class WebtoCaseEmailServiceHandler_Test {
    public static testMethod void TestMyController() {
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
       
        Case opp = new Case();
        opp.origin='web';
        opp.status='solved';
        
        opp.Subject='test';
        insert opp;
        Case caseobj=[SELECT id, CaseNumber from case where id=:opp.Id limit 1];
        // setup the data for the email
        email.subject = 'Re:Test Email Subject -Case#['+caseobj.CaseNumber+']';
        System.debug('case number'+email.subject);
        env.fromAddress = 'mailto:sakshis@damcogroup.com';
        
        
        //add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        WebtoCaseEmailServiceHandler emailProcess = new WebtoCaseEmailServiceHandler();
        emailProcess.handleInboundEmail(email, env);
       /* Attachment a = [select name from attachment where parentId = :opp.Id];
        ContentVersion cv = [select id, ContentDocumentId from ContentVersion WHERE FirstPublishLocationId =:opp.Id];
        System.assertEquals(a.name,'textfile.txt');*/
    
    }
    
    
}