/*global class WebtoCaseEmailServiceHandler implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          return result;
      }
  }*/
global class WebtoCaseEmailServiceHandler implements Messaging.InboundEmailHandler {
    
    
    global Messaging.InboundEmailResult  handleInboundEmail(Messaging.inboundEmail email, 
                                                            Messaging.InboundEnvelope env)
    {
        system.debug('method started');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try 
        { 
            
            EmailMessage  EM=new EmailMessage();
            EM.Subject=email.subject;
            EM.HtmlBody=email.HtmlBody;
            EM.TextBody=email.plainTextBody;
            EM.Incoming=true;
            //EM.FromName=EM.FromName;
            
            String subject = EM.Subject;
            system.debug('subject is ' + subject);//Testing
            String GetrefId = subject.substringBetween('-[',']');
            system.debug('GetrefId is ' + GetrefId);//Testing
            Boolean EmailIsResponse =  subject.startsWith('Re:');
            system.debug('EmailIsResponse' +EmailIsResponse);
            
            if(EmailIsResponse){
            Task ts = new Task();
            ts.Subject = email.subject;
            ts.TaskSubtype = 'Email';
            ts.ActivityDate = Date.today();
            ts.Description = email.plainTextBody;
            ts.Type = 'Email';
            
            if(GetrefId!=null)
            {
                String concat = GetrefId.substring(0,3);
                if(concat=='006'){
                    ts.WhatID= GetrefId;
                    system.debug('Inside task');
                }
                else
                {
                    //ts.WhatID=GetrefId;
                    EM.RelatedToId=GetrefId;
                    
                }
                //ts.WhoID       =  GetrefId;
                ts.Status = 'Completed';
                insert ts;
                insert EM;
                system.debug('task' +ts);
            }
            List<Case> OppinUse = [Select Id,Description FROM Case WHERE Id = :GetrefId];
                system.debug('OppinUse' +OppinUse);
            List<ContentVersion> attList = new List<ContentVersion>();
            // This will extract all blob attachments from email
            // For text type attachment Messaging.Inboundemail.TextAttachment can be used
            
            for(Case opp :OppinUse){
                //opp.Pricing_Request__c = system.today();
                opp.Description = 'test Description';
                system.debug('in for loop');
            }
            Update OppinUse;
            
            
            if(email.binaryAttachments!=null){
                system.debug('check for attachment');
                List<ContentVersion>cvList = new List<ContentVersion>();
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                
                for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                    ContentVersion testContentInsert = new ContentVersion();
                    testContentInsert.Title = binAttach.fileName;
                    testContentInsert.VersionData = binAttach.body;
                    testContentInsert.PathOnClient = '/' + binAttach.fileName ;
                    cvList.add(testContentInsert);
                    
                }
                if(cvList.size()>0){
                    insert cvList;
                }
                system.debug('FileRecordInserted' +cvList);
                cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
                for (ContentVersion cv : cvList) {
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = cv.ContentDocumentId;
                    cl.LinkedEntityId = GetrefId ; //Shared with record ID
                    cl.ShareType = 'V';
                    cl.Visibility = 'AllUsers';
                    cdlList.add(cl);
                    
                    
                    
                }
                if(cdlList.size()>0){
                    insert cdlList; 
                }
                system.debug('FileRecordInserted22' +cdlList);
                
                
            }
            
            }
            
            // System.debug('New Task Object: ' + vCon.name+vCon.id);   
        }
        // If an exception occurs when the query accesses 
        // the contact record, a QueryException is thrown.
        // The exception is written to the Apex debug log.
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        // Set the result to true. No need to send an email back to the user 
        // with an error message
        result.success = true;
        
        // Return the result for the Apex Email Service
        return result;
    }
}