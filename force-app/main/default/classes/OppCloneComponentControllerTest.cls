/**
* Created by johnpernock from OpenGate Consulting on 2019-08-26.
*/

@IsTest
private class OppCloneComponentControllerTest {
    @IsTest
    static void testGetOppClone() {
        Account ca = new Account(Name='testaccount');
        insert ca;
        
        Opportunity testopp = new Opportunity(Name='testopp', Industry_Tag__c='Academic',AccountId=ca.Id, StageName='Renewal', CloseDate=date.today());
        insert testopp;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = testopp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id
            //TotalPrice = Quantity * pbEntry.UnitPrice
        );
        insert oli;
        
        Test.startTest();
        OppCloneComponentController.CloneOppDetails details = OppCloneComponentController.getOppDetails(testopp.Id);
        String oppString = JSON.serialize(details.opp);
        Id clone = OppCloneComponentController.saveCloneOppData(oppString, '', oppString, 2);
        Test.stopTest();
    }
}