@isTest 
private class testRRFormController {
    static testMethod void testRRFormController(){
		
		Royalty_Request__c rr = new Royalty_Request__c(Account_Street__c='123 test');
		insert rr;
		
        test.startTest();
        
        PageReference ofpage = Page.RRFormPage;
        Test.setCurrentPage( ofpage );
        ApexPages.currentPage().getParameters().put( 'id', rr.id );
    
        RRFormController controller = new RRFormController();
        
        controller.getR_Request();
        controller.createRR();
        
        test.stopTest();
    }

    static testMethod void testOrderFormControllerSkuid(){
		
		Royalty_Request__c rr = new Royalty_Request__c(Account_Street__c='123 test');
		insert rr;
		
        test.startTest();

        RRFormController_Skuid.CreateRoyaltyRequestObj testRequest = new RRFormController_Skuid.CreateRoyaltyRequestObj();
        testRequest.rrRequestId = rr.Id;
        List <RRFormController_Skuid.CreateRoyaltyRequestObj> rrRequests = new List<RRFormController_Skuid.CreateRoyaltyRequestObj>();
        rrRequests.add(testRequest);
        List<boolean> results = RRFormController_Skuid.CreateRoyaltyRequest(rrRequests);
        
        test.stopTest();
    }
}