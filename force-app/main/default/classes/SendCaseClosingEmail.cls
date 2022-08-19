/**
 * Created by wmccu on 9/7/2021.
 */

global class SendCaseClosingEmail {
    @InvocableMethod(Label='Send case closing emails for parent case and all child cases')
    global static List<SendCaseClosingEmailResult> sendCaseClosingEmails
            (List<SendCaseClosingEmailRequest> requests) {
        List<SendCaseClosingEmailResult> results = new List<SendCaseClosingEmailResult>();
        for (SendCaseClosingEmailRequest request : requests) {
            results.add(sendCaseClosingEmail(request));
        }
        return results;
    }
    public static SendCaseClosingEmailResult sendCaseClosingEmail(SendCaseClosingEmailRequest request) {
        SendCaseClosingEmailResult caseClosingEmailResult = new SendCaseClosingEmailResult();
        Id parentCaseId = Id.valueOf(request.ParentCaseId);
        Id emailTemplateId = Id.valueOf(request.EmailTemplateId);
        Id owe = Id.valueOf(request.SendFromId);
        Boolean hasErrors = false;
        //get parent and child case data including contact data
        Map<Id, Case> closingCaseMap = new Map<Id, Case>([
                SELECT Id, CaseNumber, ParentId, ContactId, Contact.IsEmailBounced, Contact.Email
                FROM Case
                WHERE ParentId = :parentCaseId OR Id = :parentCaseId
                ORDER BY CaseNumber
        ]);
        //when processing each case's email, contact is missing email or isbounced=true, then has errors = true
        //and add to a string with case number, contact number and contact has a no email address or a bounced email address
        String resultMessage = '';
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Case currentCase : closingCaseMap.values()) {
            if (currentCase.ContactId != null && currentCase.Contact.IsEmailBounced == false && String.isNotEmpty(currentCase.Contact.Email)) {
                //create email message and add to list
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(currentCase.Id);
                mail.setTemplateId(emailTemplateId);
                mail.setTargetObjectId(currentCase.ContactId);
                mail.saveAsActivity = true;
                // Set list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add(currentCase.Contact.Email);
                mail.setToAddresses(sendTo);
                // Set who the email is sent from
                //Use Organization Wide Email Address found earlier
                mail.setOrgWideEmailAddressId(owe);
                //suppress adding the user's signature
                mail.setUseSignature(false);
                emailMessages.add(mail);
            } else {
                hasErrors = true;
                resultMessage += 'Case ' + currentCase.CaseNumber + ' has no Contact set or has a missing or bad email address';
            }
        }
        //send email
        try {
            Messaging.sendEmail (emailMessages);
        } catch (Exception e) {
            hasErrors = true;
            resultMessage = e.getMessage() + ' --- ' + resultMessage;
        }
        //return result
        caseClosingEmailResult.ResultHasErrors = hasErrors;
        caseClosingEmailResult.ResponseMessage = resultMessage;
        return caseClosingEmailResult;
    }

    global class SendCaseClosingEmailRequest {
        @InvocableVariable(Description='Id of email template to use.' Required=true)
        global String EmailTemplateId;
        @InvocableVariable(Description='Id of the organization wide address or user to show as the "from" on the email.' Required=true)
        global String SendFromId;
        @InvocableVariable(Description='Id of the parent case that is closing. Logic will query for all child cases.' Required=true)
        global String ParentCaseId;
    }

    global class SendCaseClosingEmailResult {
        @InvocableVariable(Description='Boolean that indicates that sending emails for that parent case had errors or not.')
        global Boolean ResultHasErrors;
        @InvocableVariable(Description='Text of errors encountered when sending emails.')
        global String ResponseMessage;
    }

    class SendCaseClosingEmailException extends Exception {

    }

}