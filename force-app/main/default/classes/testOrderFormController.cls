@isTest 
private class testOrderFormController {
    @TestSetup
    static void SetupTestOrderFormControllerData(){
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
    }
    static testMethod void testOrderFormController(){
		
		Account ca = new Account(Name='testaccount');
		insert ca;
		Opportunity testopp = new Opportunity(Name='testopp1', Industry_Tag__c='Academic',AccountId=ca.Id, StageName='Renewal', CloseDate=date.today());
		insert testopp;
//		Contract testcontract = new Contract(Name='testcontract25556',Related_Opportunity__c=testopp.Id,AccountId=ca.Id);
//		insert testcontract;
        Contact invoicecontact = new Contact(FirstName='Joe',LastName='Test1',AccountId=ca.Id);
        insert invoicecontact;
        OpportunityContactRole opcr_ic = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Invoice Contact');
		insert opcr_ic;
        OpportunityContactRole opcr_cc = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Counter');
		insert opcr_cc;
        OpportunityContactRole opcr_caa = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Customer Account Admin');
		insert opcr_caa;
        
        test.startTest();
        
        PageReference ofpage = Page.OrderFormPage;
        Test.setCurrentPage( ofpage );
        ApexPages.currentPage().getParameters().put( 'id', testopp.id );
    
        OrderFormController controller = new OrderFormController();
        
        controller.getOpportunity();
        controller.getContract();
        controller.createOrder();
        controller.getProdCount();
        controller.getInvoiceContact();
        controller.getCounterContact();
        controller.getCustomerAccountAdmin();
        
        test.stopTest();
    }

    static testMethod void testOrderFormControllerV2(){

        Account ca = new Account(Name='testaccount2');
        insert ca;
        Opportunity testopp = new Opportunity(Name='testopp3', Industry_Tag__c='Academic',AccountId=ca.Id, StageName='Renewal', CloseDate=date.today());
        insert testopp;
//		Contract testcontract = new Contract(Name='testcontract25556',Related_Opportunity__c=testopp.Id,AccountId=ca.Id);
//		insert testcontract;
        Contact invoicecontact = new Contact(FirstName='Joe',LastName='Test3',AccountId=ca.Id);
        insert invoicecontact;
        OpportunityContactRole opcr_ic = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Invoice Contact');
        insert opcr_ic;
        OpportunityContactRole opcr_cc = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Counter');
        insert opcr_cc;
        OpportunityContactRole opcr_caa = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Customer Account Admin');
        insert opcr_caa;

        test.startTest();

        PageReference ofpage = Page.OrderFormPage_V2;
        Test.setCurrentPage( ofpage );
        ApexPages.currentPage().getParameters().put( 'id', testopp.id );

        OrderFormController_V2 controller = new OrderFormController_V2();

        controller.getOpportunity();
        controller.getContract();
        controller.getProdCount();
        controller.getInvoiceContact();
        controller.getCounterContact();
        controller.getCustomerAccountAdmin();

        test.stopTest();
    }

    static testMethod void testOrderFormControllerSkuid(){
		
		Account ca = new Account(Name='testaccount3');
		insert ca;
		Opportunity testopp = new Opportunity(Name='testopp2', Industry_Tag__c='Academic',AccountId=ca.Id, StageName='Renewal', CloseDate=date.today());
		insert testopp;
//		Contract testcontract = new Contract(Name='testcontract5242532',Related_Opportunity__c=testopp.Id,AccountId=ca.Id);
//		insert testcontract;
        Contact invoicecontact = new Contact(FirstName='Joe',LastName='Test2',AccountId=ca.Id);
        insert invoicecontact;
        OpportunityContactRole opcr_ic = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Invoice Contact');
		insert opcr_ic;
        OpportunityContactRole opcr_cc = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Counter');
		insert opcr_cc;
        OpportunityContactRole opcr_caa = new OpportunityContactRole(OpportunityId=testopp.Id,ContactId=invoicecontact.Id,Role='Customer Account Admin');
		insert opcr_caa;
        
        test.startTest();

        OrderFormController_Skuid.OrderFormRequest testRequest = new OrderFormController_Skuid.OrderFormRequest();
        testRequest.oppId = testopp.Id;
        List <OrderFormController_Skuid.OrderFormRequest> orderRequests = new List<OrderFormController_Skuid.OrderFormRequest>();
        orderRequests.add(testRequest);
        List<boolean> results = OrderFormController_Skuid.OrderFormCreate(orderRequests);
        
        test.stopTest();
    }
}