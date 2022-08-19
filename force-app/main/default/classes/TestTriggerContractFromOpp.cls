@IsTest(SeeAllData=true)
public with sharing class TestTriggerContractFromOpp {
	//TODO Delete this class
//	@IsTest
//	static void validateContractFromOpp() {
//		Account a = new Account(Name='testaccount');
//		insert a;
//		Opportunity o = new Opportunity(Name='testopp', AccountId=a.Id, Type='New Business',
//							StageName='Renewal', CloseDate=Date.today(), Contract_Required__c='Yes', LeadSource='Renewal');
//		insert o;
//		Opportunity o2 = new Opportunity(Name='testopp2', AccountId=a.Id, Type='New Business',
//							StageName='Renewal', CloseDate=Date.today(), Contract_Required__c='No', LeadSource='Renewal');
//		insert o2;
//		Product2 p = new Product2(Name='testproduct');
//		insert p;
//		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard=TRUE LIMIT 1];
//		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
//        insert standardPrice;
//		Pricebook2 pb = new Pricebook2(Name='testpb');
//		insert pb;
//		PricebookEntry pbe = new PricebookEntry(Product2Id=p.Id, Pricebook2Id=pb.Id, UnitPrice=1.00, IsActive = true, UseStandardPrice=false);
//		insert pbe;
//		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Quantity=1, PricebookEntryId=pbe.Id, UnitPrice=1.00);
//		insert oli;
//
////		delete oli;
//
//		o2.Contract_Required__c = 'Yes';
//		update o2;
//	}

}