/**
 * Created by wmccu on 9/7/2021.
 */

@IsTest
private class SendCaseClosingEmailTest {
    @TestSetup
    static void setupSendCaseClosingEmailTestData() {
        //record type ids
        Id salesViewRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Sales View').getRecordTypeId();
        Id standardContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard Contact').getRecordTypeId();
        Id issCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ISS Case').getRecordTypeId();
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            //email template
            EmailTemplate caseEmailTemplate = new EmailTemplate();
            caseEmailTemplate.isActive = true;
            caseEmailTemplate.Name = 'Case Closing Email';
            caseEmailTemplate.DeveloperName = 'case_closing_email';
            caseEmailTemplate.TemplateType = 'text';
            caseEmailTemplate.Subject = 'Case Closed';
            caseEmailTemplate.Body = 'This is my closing email';
            caseEmailTemplate.FolderId = UserInfo.getUserId();
            insert caseEmailTemplate;
        }
        //account
        Account account = new Account(
                Name = 'Amazing Co.',
                RecordTypeId = salesViewRecordTypeId,
                BillingCountry = 'United States',
                BillingState = 'Washington',
                Oracle_Account_Number__c = '1345078'
        );
        insert account;
        //contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 5; i++) {
            String inc = String.valueOf(i);
            contacts.add(
                    new Contact(
                            FirstName = 'Test' + inc,
                            LastName = 'AmazingTest' + inc,
                            Email = 'test' + inc + 'amazingtest' + inc + '@email.com',
                            RecordTypeId = standardContactRecordTypeId,
                            AccountId = account.Id
                    )
            );
        }
        insert contacts;
        //case
        Case parentCase = new Case(
                AccountId = account.Id,
                ContactId = contacts[0].Id,
                Subject = 'Parent Case',
                Check_If_Parent_Case__c = true
        );
        insert parentCase;
        //child cases
        List<Case> childCases = new List<Case>();
        for (Integer i = 1; i < 4; i++) {
            childCases.add(
                    new Case(
                            AccountId = account.Id,
                            ContactId = contacts[i].Id,
                            Subject = 'Child Case' + String.valueOf(i),
                            Check_If_Parent_Case__c = false
                    )
            );
        }
        insert childCases;
    }
    @IsTest
    static void shouldSendCaseClosingEmail() {
        EmailTemplate caseEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'case_closing_email'];
        Case parentCase = [SELECT Id, Subject, ContactId FROM Case WHERE Subject = 'Parent Case'];
        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        SendCaseClosingEmail.SendCaseClosingEmailRequest request = new SendCaseClosingEmail.SendCaseClosingEmailRequest();
        request.EmailTemplateId = caseEmailTemplate.Id;
        request.ParentCaseId = parentCase.Id;
        request.SendFromId = orgWideEmailAddress.Id;
        Test.startTest();
        {
            List<SendCaseClosingEmail.SendCaseClosingEmailResult> results = SendCaseClosingEmail.sendCaseClosingEmails(new List<SendCaseClosingEmail.SendCaseClosingEmailRequest>{
                    request
            });
            System.debug(results);
            for (SendCaseClosingEmail.SendCaseClosingEmailResult sendCaseClosingEmailResult : results) {
                System.assert(sendCaseClosingEmailResult.ResultHasErrors == false, 'There should be no errors in any result');
            }
        }
        Test.stopTest();
    }
    @IsTest
    static void missingEmailAddressShouldReturnError() {
        //clear email on contacts
        List<Contact> contacts = [SELECT Id, Name, Email, IsEmailBounced FROM Contact];
        for (Contact contact : contacts) {
            contact.Email = null;
        }
        update contacts;
        EmailTemplate caseEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'case_closing_email'];
        Case parentCase = [SELECT Id, Subject, ContactId FROM Case WHERE Subject = 'Parent Case'];
        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        SendCaseClosingEmail.SendCaseClosingEmailRequest request = new SendCaseClosingEmail.SendCaseClosingEmailRequest();
        request.EmailTemplateId = caseEmailTemplate.Id;
        request.ParentCaseId = parentCase.Id;
        request.SendFromId = orgWideEmailAddress.Id;
        Test.startTest();
        {
            List<SendCaseClosingEmail.SendCaseClosingEmailResult> results = SendCaseClosingEmail.sendCaseClosingEmails(new List<SendCaseClosingEmail.SendCaseClosingEmailRequest>{
                    request
            });
            System.debug(results);
            for (SendCaseClosingEmail.SendCaseClosingEmailResult sendCaseClosingEmailResult : results) {
                System.assert(sendCaseClosingEmailResult.ResultHasErrors == true, 'ResultHasErrors should be true since none of the contacts have an email address');
            }
        }
        Test.stopTest();

    }
    @IsTest
    static void noContactIdShouldReturnError() {
        EmailTemplate caseEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'case_closing_email'];
        Case parentCase = [SELECT Id, Subject, ContactId FROM Case WHERE Subject = 'Parent Case'];
        //clear the contact id on the parent case
        parentCase.ContactId = null;
        update parentCase;
        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        SendCaseClosingEmail.SendCaseClosingEmailRequest request = new SendCaseClosingEmail.SendCaseClosingEmailRequest();
        request.EmailTemplateId = caseEmailTemplate.Id;
        request.ParentCaseId = parentCase.Id;
        request.SendFromId = orgWideEmailAddress.Id;
        Test.startTest();
        {
            List<SendCaseClosingEmail.SendCaseClosingEmailResult> results = SendCaseClosingEmail.sendCaseClosingEmails(new List<SendCaseClosingEmail.SendCaseClosingEmailRequest>{
                    request
            });
            System.debug(results);
            for (SendCaseClosingEmail.SendCaseClosingEmailResult sendCaseClosingEmailResult : results) {
                System.assert(sendCaseClosingEmailResult.ResultHasErrors == true, 'ResultHasErrors should be true since there is no ContacId for the parent case');
            }
        }
        Test.stopTest();

    }


}