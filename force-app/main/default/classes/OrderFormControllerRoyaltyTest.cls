/**
 * Created by wmccu on 12/17/2020.
 */

@IsTest
private class OrderFormControllerRoyaltyTest {
    @TestSetup
    static void setupOrderFormControllerRoyaltyTestData() {
         
   
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {


        Group g1 = new Group(Name='Support Queue', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        }
        Group group1 = [SELECT ID FROM Group where Name = 'Support Queue'];
        Account bucketASTM = new Account(Name = 'BucketAccount');
        insert bucketASTM;
        OrderFormControllerSettings__c OrderFormSetting = new OrderFormControllerSettings__c();
        OrderFormSetting.ASTM_Bucket_Account__c	= bucketASTM.id;
        OrderFormSetting.Support_Queue_Id__c = group1.id;
        insert OrderFormSetting;
    
        Account testAccount = new Account(
                Name = 'Test Account',
                BillingStreet = '100 East Pratt Street',
                BillingCity = 'Baltimore',
                BillingStateCode = 'MD',
                BillingPostalCode = '21212',
                BillingCountryCode = 'US',
                ShippingStreet = '100 East Pratt Street',
                ShippingCity = 'Baltimore',
                ShippingStateCode = 'MD',
                ShippingPostalCode = '21212',
                ShippingCountryCode = 'US',
                Oracle_Account_Number__c = '99118822'
        );
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = testAccount.Id,
                Type = 'New Business',
                StageName = 'New Business',
                CloseDate = Date.today(),
                LeadSource = '',
//                Pricebook2Id = standardPricebook.Id,
                Contract_Required__c = 'No',
                Amount = 1000,
                Purchase_Order_Number__c = '1234',
                IP_Address_Type__c = '',
                Approval_Date__c = Date.today(),
                Approval_Status__c = 'Approved',
                Comments__c = 'test',
                ASTM_Product_Setup_Required__c = 'Yes',
                Contract_Start_Date_del__c = Date.today(),
                Contract_End_Date__c = Date.today().addDays(365),
                Counter_Subscription__c = 'No',
                Delivery_Mechanism__c = 'ASTM Compass',
                DRM_On_or_Off__c = 'Off',
                Estimated_Number_of_Users__c = 10,
                Existing_Revenue__c = 1000000,
                Forced_Login__c = 'No',
                Industry_Tag__c = 'Corporate',
                Number_of_Locations__c = '3',
                Number_of_Standards__c = 5,
                Payment_Date__c = Date.today().addDays(30),
                Payment_Frequency__c = 'Quarterly',
                Product_Mix__c = 'Custom Collections',
                Misc_Comments__c = 'test',
                Response_Due_Date__c = Date.today().addDays(45),
                Royalty_Amount__c = 100,
                Royalty_Expiration_Date__c = Date.today().addDays(180),
                Sale_Type__c = 'New',
                URL__c = 'https://www.test.com',
                Usage_Reports_Hidden__c = 'Yes',
                Watermark__c = 'test'
        );
        insert testOpportunity;
    }
    @IsTest
    static void testRoyaltyFormController() {
        Opportunity getOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        System.debug(getOpportunity);
        Test.startTest();
        PageReference exportPage = new PageReference('/apex/CreateOrderFormRoyalty');
        Test.setCurrentPage(exportPage);
        exportPage.getParameters().put('id', String.valueOf(getOpportunity.Id));
        System.debug(exportPage);
        OrderFormControllerRoyalty newController = new OrderFormControllerRoyalty();
        System.debug(newController);
        newController.getOpportunity();
        newController.getProdCount();
        newController.getProds();
        Test.stopTest();
    }
    @IsTest
    static void testCreateOrder() {
        Opportunity getOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Test.startTest();
        PageReference pageReference = Page.CreateOrderFormRoyalty;
        Test.setCurrentPageReference(pageReference);
        pageReference.getParameters().put('id', getOpportunity.Id);
        OrderFormControllerRoyalty newController = new OrderFormControllerRoyalty();
        PageReference objectPageReference = newController.createOrder();
        Test.stopTest();

    }
}