/**
 * Created by wmccu on 9/28/2021.
 */

@IsTest
private class GrowthLogicBatchTest {
    @TestSetup
    static void setupGrowthLogicBatchTestData() {
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
                Contract_Required__c = 'No',
                Amount = 1
        );
        insert opportunity;
        System.debug(opportunity);
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Product2Id = standardPricebookEntries[0].Id,
                Quantity = 1,
                UnitPrice = 1
        );
        insert opportunityLineItem;
        Account account2 = new Account(
                Name = 'Non Managed Customer',
                Account_Mgt__c = 'Non Managed Account',
                BillingCountryCode = 'US'
        );
        insert account2;
        Opportunity opportunity2 = new Opportunity(
                Name = 'Test Non Managed New Business',
                AccountId = account2.Id,
                Type = 'New Business',
                StageName = 'Closed Won',
                CloseDate = Date.today().addYears(-1),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'Yes',
                Amount = 1000
        );
        insert opportunity2;
        //insert opportunities to support calculated growth
        Account account3 = new Account(
                Name = 'Calculated Customer',
                Account_Mgt__c = 'Managed Account',
                BillingCountryCode = 'US'
        );
        insert account3;
        Opportunity opportunity3 = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account3.Id,
                Type = 'New Business',
                StageName = 'Closed Won',
                CloseDate = Date.today().addYears(-1),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'No',
                Amount = 1000
        );
        insert opportunity3;
    }
    @IsTest
    static void invocableShouldRunBatch() {
        Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ASTM').getRecordTypeId();
        List<Account> accounts = [SELECT Id, Name, Account_Mgt__c FROM Account];
        System.assertEquals(3, accounts.size());
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Set<String> opportunityTypes = new Set<String>{
                'New Business', 'Renewal', 'Renewal with Upgrade', 'Expansion on Existing Account'
        };
        List<Opportunity> opportunities = new List<Opportunity>();
        Integer monthsBack = -2;
        for (Account account : accounts) {
            for (String opportunityType : opportunityTypes) {
                Opportunity opportunity = new Opportunity(
                        Name = 'Test Opportunity' + String.valueOf(monthsBack),
                        AccountId = account.Id,
                        Type = opportunityType,
                        StageName = 'Renewal',
                        CloseDate = Date.today().addMonths(monthsBack),
                        LeadSource = 'Renewal',
                        Pricebook2Id = standardPricebook.Id,
                        Contract_Required__c = 'No',
                        Amount = 1,
                        RecordTypeId = astmRecordTypeId
                );
                if (Math.mod(monthsBack, 2) == 0) {
                    opportunity.StageName = 'Closed Won';
                }
                opportunities.add(opportunity);
                monthsBack = monthsBack - 1;
            }
        }
        Test.startTest();
        {
            GrowthLogicBatch.executeGrowthLogicBatch();
        }
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [
                SELECT Id, Name, CloseDate, StageName, Recalculate_Growth__c
                FROM Opportunity
                WHERE AccountId IN :accounts
        ];
        System.debug(verifyOpportunities);
    }
    @IsTest
    static void executeShouldRunBatch() {
        Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ASTM').getRecordTypeId();
        List<Account> accounts = [SELECT Id, Name, Account_Mgt__c FROM Account];
        System.assertEquals(3, accounts.size());
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Set<String> opportunityTypes = new Set<String>{
                'New Business', 'Renewal', 'Renewal with Upgrade', 'Expansion on Existing Account'
        };
        List<Opportunity> opportunities = new List<Opportunity>();
        Integer monthsBack = -2;
        for (Account account : accounts) {
            for (String opportunityType : opportunityTypes) {
                Opportunity opportunity = new Opportunity(
                        Name = 'Test Opportunity' + String.valueOf(monthsBack),
                        AccountId = account.Id,
                        Type = opportunityType,
                        StageName = 'Renewal',
                        CloseDate = Date.today().addMonths(monthsBack),
                        LeadSource = 'Renewal',
                        Pricebook2Id = standardPricebook.Id,
                        Contract_Required__c = 'No',
                        Amount = 1,
                        RecordTypeId = astmRecordTypeId
                );
                if (Math.mod(monthsBack, 2) == 0) {
                    opportunity.StageName = 'Closed Won';
                }
                opportunities.add(opportunity);
                monthsBack = monthsBack - 1;
            }
        }
        Test.startTest();
        {
            String query = 'SELECT Id, Recalculate_Growth__c FROM Opportunity';
            GrowthLogicBatch batchJob = new GrowthLogicBatch(query);
            Database.executeBatch(batchJob);
        }
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [
                SELECT Id, Name, CloseDate, StageName, Recalculate_Growth__c
                FROM Opportunity
                WHERE AccountId IN :accounts
        ];
        System.debug(verifyOpportunities);
    }
    @IsTest
    static void scheduledHelperClassShouldAddSchedule() {
        GrowthLogicBatch.removeGrowthLogicBatch();
        Test.startTest();
        GrowthLogicBatch.scheduleGrowthLogicBatch();
        Test.stopTest();
    }
}