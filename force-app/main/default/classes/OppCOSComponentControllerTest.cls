/**
 * Created by johnpernock from OpenGate Consulting on 2019-08-26.
 */

@IsTest
private class OppCOSComponentControllerTest {
    @IsTest
    static void shouldCloneOpportunity() {
        Account account = new Account(Name='Test Account');
        insert account;

        Opportunity  originalOpportunity = new Opportunity(Name='testopp', Industry_Tag__c='Academic',AccountId=account.Id, StageName='Renewal', CloseDate=Date.today());
        insert originalOpportunity;

        Test.startTest();
        Id clonedId = OppCOSComponentController.cloneOriginalOpp(originalOpportunity.Id);
        System.assert(clonedId != null);
        Test.stopTest();
        Opportunity verifyOpportunity = [SELECT Id, Name, Growth__c FROM Opportunity WHERE Id = :clonedId];
        System.assert(verifyOpportunity.Growth__c == 0);
    }
}