/**
 * Created by wmccu on 1/5/2021.
 */

@IsTest
private class OpportunityLineItemActionsTest {
    @TestSetup
    static void setupOpportunityLineItemActionsTestData() {
        //create products
        List<Product2> ASTMProducts = new List<Product2>();
        List<String> productStrings = new List<String>{
                'ASTM Digital Library Technical Publications', 'Asset Management Standards', 'Admin/Service Fee'
        };
        for (String str : productStrings) {
            System.debug(str);
            Product2 addProduct2 = new Product2(
                    Name = str,
                    IsActive = true,
                    Family = 'Publications'
            );
            ASTMProducts.add(addProduct2);
        }
        insert ASTMProducts;
        List<Product2> verifyInsertedProduct2s = [SELECT Id FROM Product2];
        System.assertEquals(productStrings.size(), verifyInsertedProduct2s.size(), 'There should be products inserted in the setup');
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        update standardPricebook;
        //insert an ASTM pricebook
        Pricebook2 ASTMPricebook2 = new Pricebook2(
                Name = 'ASTM',
                IsActive = true
        );
        insert ASTMPricebook2;
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        System.assertEquals(true, standardPricebook.IsStandard);
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        for (Product2 product2 : ASTMProducts) {
            PricebookEntry pbe = new PricebookEntry(
                    Pricebook2Id = standardPricebook.Id,
                    Product2Id = product2.Id,
                    UnitPrice = 1,
                    IsActive = true
            );
            standardPricebookEntries.add(pbe);
        }
        insert standardPricebookEntries;
        //setup a customer and test opportunity
        Account account = new Account(
                Name = 'Test Customer Managed',
                Account_Mgt__c = 'Managed Account',
                BillingCountryCode = 'US'
        );
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Amount = 1,
                Contract_Required__c = 'Yes'
        );
        insert opportunity;
    }
    @IsTest
    static void insertedLineItemShouldUpdateContract() {
        Opportunity opportunity = [
                SELECT Id, Name, Contract_Required__c, ContractId
                FROM Opportunity
                WHERE Type = 'New Business'
        ];
        System.assert(opportunity.ContractId != null);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        List<PricebookEntry> standardPricebookEntries = [SELECT Id, Name FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id];
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Product2Id = standardPricebookEntries[0].Id,
                Quantity = 1,
                UnitPrice = 1
        );
        Test.startTest();
        insert opportunityLineItem;
        Test.stopTest();
        Contract verifyContract = [
                SELECT Id, Products__c, Contract_Renewal_Amount__c
                FROM Contract
                WHERE Id = :opportunity.ContractId
        ];
        System.debug(verifyContract);
    }
    @IsTest
    static void updatedLineItemShouldUpdateContract() {
        Opportunity opportunity = [
                SELECT Id, Name, Contract_Required__c, ContractId
                FROM Opportunity
                WHERE Type = 'New Business'
        ];
        System.assert(opportunity.ContractId != null);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        List<PricebookEntry> standardPricebookEntries = [SELECT Id, Name FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id];
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Product2Id = standardPricebookEntries[0].Id,
                Quantity = 1,
                UnitPrice = 1
        );
        insert opportunityLineItem;
        Test.startTest();
        opportunityLineItem.UnitPrice = 20;
        update opportunityLineItem;
        Test.stopTest();
        Contract verifyContract = [
                SELECT Id, Products__c, Contract_Renewal_Amount__c
                FROM Contract
                WHERE Id = :opportunity.ContractId
        ];
        System.debug(verifyContract);
    }
    @IsTest
    static void deletedLineItemShouldUpdateContract() {
        Opportunity opportunity = [
                SELECT Id, Name, Contract_Required__c, ContractId
                FROM Opportunity
                WHERE Type = 'New Business'
        ];
        System.assert(opportunity.ContractId != null);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        List<PricebookEntry> standardPricebookEntries = [SELECT Id, Name FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id];
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Product2Id = standardPricebookEntries[0].Id,
                Quantity = 1,
                UnitPrice = 1
        );
        insert opportunityLineItem;
        Test.startTest();
        delete opportunityLineItem;
        Test.stopTest();
        Contract verifyContract = [
                SELECT Id, Products__c, Contract_Renewal_Amount__c
                FROM Contract
                WHERE Id = :opportunity.ContractId
        ];
        System.debug(verifyContract);
    }
}