/**
 * Created by johnpernock from OpenGate Consulting on 2019-04-30.
 */

@IsTest
private class CloneChildOppsTest {
    @TestSetup
    static void setupCloneChildOppsTestData() {
        Account testAccount = new Account(Name = 'Test Parent Account');
        insert testAccount;

        Account testChildAccount = new Account(Name = 'Test Child Account', ParentId = testAccount.Id);
        insert testChildAccount;

        Opportunity testChildMainOpp = new Opportunity(Name='Test Main 1', Industry_Tag__c='Academic',AccountId=testChildAccount.Id, StageName='Renewal', CloseDate=date.today());
        insert testChildMainOpp;

        Contact invoicecontact = new Contact(FirstName='Joe',LastName='Test1',AccountId=testChildAccount.Id);
        insert invoicecontact;

        OpportunityContactRole opcr_ic = new OpportunityContactRole(OpportunityId=testChildMainOpp.Id,ContactId=invoicecontact.Id,Role='Invoice Contact');
        insert opcr_ic;

        OpportunityContactRole opcr_cc = new OpportunityContactRole(OpportunityId=testChildMainOpp.Id,ContactId=invoicecontact.Id,Role='Counter');
        insert opcr_cc;

        OpportunityContactRole opcr_caa = new OpportunityContactRole(OpportunityId=testChildMainOpp.Id,ContactId=invoicecontact.Id,Role='Customer Account Admin');
        insert opcr_caa;

//        OpportunityLineItem newTestChildMainLineItem = new OpportunityLineItem();
//        insert newTestChildMainLineItem;

        Contact invoicecontact2 = new Contact(FirstName='Joe',LastName='Test2',AccountId=testChildAccount.Id);
        insert invoicecontact2;

        Opportunity testChildMainCOSOpp = new Opportunity(Name='Test Main Child 1', Industry_Tag__c='Academic',AccountId=testChildAccount.Id, StageName='Renewal', CloseDate=date.today(), Change_of_Scope__c=true, Original_Opportunity__c=testChildMainOpp.Id);
        insert testChildMainCOSOpp;

        OpportunityContactRole opcr_ic2 = new OpportunityContactRole(OpportunityId=testChildMainCOSOpp.Id,ContactId=invoicecontact2.Id,Role='Invoice Contact');
        insert opcr_ic2;

        OpportunityContactRole opcr_cc2 = new OpportunityContactRole(OpportunityId=testChildMainCOSOpp.Id,ContactId=invoicecontact2.Id,Role='Counter');
        insert opcr_cc2;

        OpportunityContactRole opcr_caa2 = new OpportunityContactRole(OpportunityId=testChildMainCOSOpp.Id,ContactId=invoicecontact2.Id,Role='Customer Account Admin');
        insert opcr_caa2;

//        OpportunityLineItem newTestChildCOSLineItem = new OpportunityLineItem();
//        insert newTestChildCOSLineItem;

    }
    @IsTest
    static void testChildOppClone() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Parent Account'];
        CloneChildOppsController.CloneChildCreateRequest newCloneRequest = new CloneChildOppsController.CloneChildCreateRequest();
        newCloneRequest.acctId = testAccount.Id;
        Test.startTest();
        CloneChildOppsController.CloneChildCreate(new List<CloneChildOppsController.CloneChildCreateRequest>{newCloneRequest});
        Test.stopTest();
    }
}