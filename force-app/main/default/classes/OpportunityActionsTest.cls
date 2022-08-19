/**
 * Created by wmccu on 9/25/2020.
 */

@IsTest
private class OpportunityActionsTest {
    @TestSetup
    static void setupOpportunityActionsTestData() {
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
    static void shouldCreateContractWhenContractRequiredYesOnInsert() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Customer Managed'];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'Yes',
                Amount = 1
        );
        Test.startTest();
        insert opportunity;
        Test.stopTest();
    }
    @IsTest
    static void shouldCreateContractWhenContractRequiredUpdatedYes() {
        List<Opportunity> opportunities = [SELECT Id, Name, Contract_Required__c FROM Opportunity LIMIT 1];
        System.debug(opportunities);
        opportunities[0].Contract_Required__c = 'Yes';
        Test.startTest();
        update opportunities;
        Test.stopTest();
    }
    @IsTest
    static void shouldSetGrowthOnOpportunities() {
        Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ASTM').getRecordTypeId();
        List<Account> accounts = [SELECT Id, Name, Account_Mgt__c FROM Account];
        System.assertEquals(3, accounts.size());
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Set<String> opportunityTypes = new Set<String>{
                'New Business', 'Renewal', 'Renewal with Upgrade', 'Expansion on Existing Account'
        };
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Account account : accounts) {
            for (String opportunityType : opportunityTypes) {
                Opportunity opportunity = new Opportunity(
                        Name = 'Test Opportunity',
                        AccountId = account.Id,
                        Type = opportunityType,
                        StageName = 'Renewal',
                        CloseDate = Date.today().addMonths(4),
                        LeadSource = 'Renewal',
                        Pricebook2Id = standardPricebook.Id,
                        Contract_Required__c = 'No',
                        Amount = 1,
                        RecordTypeId = astmRecordTypeId
                );
                opportunities.add(opportunity);
            }
        }
        Test.startTest();
        insert opportunities;
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [
                SELECT Id, Name, Account.Account_Mgt__c, Type, Growth__c
                FROM Opportunity
                WHERE Id IN :opportunities
        ];
        System.debug(verifyOpportunities);
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Account.Account_Mgt__c == 'Non Managed Account' && opportunity.Type == 'Renewal') {
                System.assertEquals(0, opportunity.Growth__c);
            }
        }
    }
    @IsTest
    static void testGetGrowthOpportunitiesMap() {
        List<Account> accounts = [SELECT Id, Name, Account_Mgt__c FROM Account WHERE Name LIKE '%Managed%'];
        System.debug(accounts);
        System.assertEquals(2, accounts.size());
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Set<String> opportunityTypes = new Set<String>{
                'New Business', 'Renewal', 'Renewal with Upgrade', 'Expansion on Existing Account'
        };
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Account account : accounts) {
            for (String opportunityType : opportunityTypes) {
                Opportunity opportunity = new Opportunity(
                        Name = 'Test Opportunity',
                        AccountId = account.Id,
                        Type = opportunityType,
                        StageName = 'Renewal',
                        CloseDate = Date.today(),
                        LeadSource = 'Renewal',
                        Pricebook2Id = standardPricebook.Id,
                        Contract_Required__c = 'No',
                        Amount = 1
                );
                System.debug(opportunity);
                opportunities.add(opportunity);
            }
        }
        Test.startTest();
        System.assertEquals(8, opportunities.size());
        Map<Id, Account> accountMap = new Map<Id, Account> (accounts);
        Map<String, List<Opportunity>> opportunityMap = OpportunityTriggerHandler.getOpportunitiesToSetGrowthBeforeInsert(opportunities, accountMap);
        Test.stopTest();
        System.debug(opportunityMap);
        System.assertEquals(4, opportunityMap.get('Amount').size());
        System.assertEquals(3, opportunityMap.get('Calculate').size());
        System.assertEquals(1, opportunityMap.get('Zero').size());
    }
    @IsTest
    static void testGetGrowthCalculationType() {
        Account account = [SELECT Id, Name, Account_Mgt__c FROM Account WHERE Name = 'Test Customer Managed'];
        String opportunityName = String.valueOf(Date.today().year()) + '-Test Customer Managed--New Business';
        System.debug(opportunityName);
        Opportunity opportunity = [SELECT Id, Name, Type FROM Opportunity WHERE Name = :opportunityName];
        Test.startTest();
        String growthCalculationType = OpportunityTriggerHandler.getGrowthCalculationType(opportunity, account);
        System.debug(growthCalculationType);
        Test.stopTest();
    }
    @IsTest
    static void shouldCalculateGrowthForManagedAccountRenewal() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Calculated Customer'];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'Renewal',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'No',
                Amount = 2000
        );
        Test.startTest();
        insert opportunity;
        Test.stopTest();
    }
    @IsTest
    static void closedWonOpportunityShouldActivateContract() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Customer Managed'];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'New Business',
                StageName = 'Renewal',
                CloseDate = Date.today(),
                LeadSource = 'Renewal',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'Yes',
                Amount = 1
        );
        insert opportunity;
        Test.startTest();
        Contract beforeUpdate = [SELECT Id, Status, Related_Opportunity__c, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :opportunity.Id];
        System.assert(beforeUpdate.Status != 'Activated');
        opportunity.StageName = 'Closed Won';
        update opportunity;
        Test.stopTest();
        Contract afterUpdate = [SELECT Id, Status, Related_Opportunity__c, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :opportunity.Id];
        System.assertEquals('Activated', afterUpdate.Status);
    }
    @IsTest
    static void newBusinessWithin3MonthsShouldShowError() {
        Account nonManaged = [SELECT Id, Name, Account_Mgt__c FROM Account WHERE Name = 'Non Managed Customer'];
        System.debug(nonManaged);
        Contract nonManagedContract = [SELECT Id, Status, Related_Opportunity__c, StartDate, EndDate FROM Contract WHERE AccountId = :nonManaged.Id];
        System.debug(nonManagedContract);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test New Business',
                AccountId = nonManaged.Id,
                Type = 'New Business',
                StageName = 'Negotiation',
                CloseDate = Date.today().addMonths(2),
                LeadSource = '',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'Yes',
                Amount = 2000
        );
        Test.startTest();
        try {
            insert opportunity;
        } catch (Exception e) {
            System.debug('catch');
            System.assert(e.getMessage().contains ('A Non Managed Account cannot have a New Business Opportunity'));
            System.debug(e.getMessage());
        }
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [SELECT Id, Name, Amount FROM Opportunity WHERE StageName = 'Negotiation'];
        System.debug(verifyOpportunities);
        System.assert(verifyOpportunities.size() == 0);
    }
    @IsTest
    static void newBusiness3MonthsFromContractEndDateShouldSave() {
        Account nonManaged = [SELECT Id, Name, Account_Mgt__c FROM Account WHERE Name = 'Non Managed Customer'];
        System.debug(nonManaged);
        Contract nonManagedContract = [SELECT Id, Status, Related_Opportunity__c, StartDate, EndDate FROM Contract WHERE AccountId = :nonManaged.Id];
        System.debug(nonManagedContract);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test New Business',
                AccountId = nonManaged.Id,
                Type = 'New Business',
                StageName = 'Negotiation',
                CloseDate = Date.today().addMonths(4),
                LeadSource = '',
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'Yes',
                Amount = 2000
        );
        Test.startTest();
        insert opportunity;
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [SELECT Id, Name, Amount FROM Opportunity WHERE StageName = 'Negotiation'];
        System.debug(verifyOpportunities);
        System.assert(verifyOpportunities.size() == 1);
    }
    @IsTest
    static void approvedOpportunityShouldSetApprovalDate() {
        Id royaltyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royalty').getRecordTypeId();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Customer Managed'];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'New Business',
                StageName = 'Proposal/Price Quote',
                CloseDate = Date.today(),
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'No',
                Amount = 1000,
                Approval_Status__c = 'Pending',
                RecordTypeId = royaltyRecordTypeId,
                Number_of_Standards__c = 99
        );
        insert opportunity;
        Test.startTest();
        opportunity.Royalty_Expiration_Date__c = Date.today().addMonths(12);
        opportunity.Submit_for_Approval__c = true;
        opportunity.Approval_Status__c = 'Approved';
        update opportunity;
        Test.stopTest();
        Opportunity verifyOpportunity = [
                SELECT Id, Name, Approval_Date__c
                FROM Opportunity
                WHERE Number_of_Standards__c = 99
        ];
        System.debug(verifyOpportunity);
        System.assert(verifyOpportunity.Approval_Date__c == Date.today(), 'Approval Date should be set to today');
    }
    @IsTest
    static void changingRecordTypeShouldRunPricebookLogic() {
        Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ASTM').getRecordTypeId();
        Id ihsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IHS').getRecordTypeId();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Customer Managed'];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE];
        Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = account.Id,
                Type = 'New Business',
                StageName = 'Proposal/Price Quote',
                CloseDate = Date.today(),
                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'No',
                Amount = 1000,
                Approval_Status__c = 'Pending',
                RecordTypeId = astmRecordTypeId,
                Number_of_Standards__c = 99
        );
        insert opportunity;
        Test.startTest();
        opportunity.RecordTypeId = ihsRecordTypeId;
        update opportunity;
        Test.stopTest();
        Opportunity verifyOpportunity = [
                SELECT Id, Name, Approval_Date__c, RecordTypeId, Account_Owner_Email__c
                FROM Opportunity
                WHERE Number_of_Standards__c = 99
        ];
        System.debug(verifyOpportunity);
        System.assert(verifyOpportunity.RecordTypeId == ihsRecordTypeId);
    }
}