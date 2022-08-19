/**
 * Created by johnpernock from OpenGate Consulting on 12/13/18.
 */

@IsTest
private class LeadTriggerTest {
    @IsTest
    static void testLeadSource() {
        Lead newLead = new Lead();
        newLead.FirstName = 'TestFirst';
        newLead.LastName = 'TestLast';
        newLead.Company = 'Test Company';
        newLead.Email = 'testFirst.testLast@example.com';
        newLead.LeadSource = 'Open';
        insert newLead;

        newLead.LeadSource = 'Qualified';
        update newLead;
    }
    @IsTest
    static void testLeadSource_Custom() {
        Lead newLead = new Lead();
        newLead.FirstName = 'TestFirst';
        newLead.LastName = 'TestLast';
        newLead.Company = 'Test Company';
        newLead.Email = 'testFirst.testLast@example.com';
        newLead.Lead_Source__c = 'Open';
        insert newLead;

        newLead.Lead_Source__c = 'Qualified';
        update newLead;
    }
}