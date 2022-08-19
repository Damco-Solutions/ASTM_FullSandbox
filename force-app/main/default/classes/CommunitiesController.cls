public with sharing class CommunitiesController {
	
	public Royalty_Request__c newRequest {get;set;}
	public String toSelect {get; set;}
	public Boolean showRequest {get; set;}
	public String selectedOppStatus{get;set;}
	public Boolean showwon {get; set;}
	public Boolean setupreq {get; set;}
	public Boolean ipreq {get; set;}
	public Boolean appurl {get; set;}
	public Boolean locations {get; set;}
	public Attachment attachment {get;set;}
	public Boolean viewClosed {get;set;}
    
	public Date fDate { get; set; }
    
    public void showlocations()
    {
    	if (newRequest.Product_Mix__c.contains('Custom Collections') ){
			locations=true;
		} else {
			locations=false;
		} 
    }
    
    public void viewClosed()
    {
			viewClosed=true;
    }
    
	public void changeipReq()
	{
	if (requestupdate.IP_Address_Type__c == 'Applet'){
			appurl=true;
		} else {
			appurl=false;
		}
	
	if (requestupdate.IP_Address_Type__c == 'IP'){
			ipreq=true;
		} else {
			ipreq=false;
		}
	}
	
	public void changeShowWon()
	{
	if (requestupdate.Opportunity_Status__c == 'Won'){
			showwon=true;
		} else {
			showwon=false;
		}
	}
	
	public void changeSetupReq()
	{
	if (requestupdate.ASTM_Product_Setup_Required__c == 'Yes'){
			setupreq=true;
		} else {
			setupreq=false;
		} 
	}
	
	public CommunitiesController() {}
	public CommunitiesController(ApexPages.StandardController controller) {
		setupreq=false;
		showwon = false;
		ipreq=false;
		appurl=false;
		newRequest = new Royalty_Request__c();
		attachment = new Attachment();
	}
	
	public User thisUser = new User();
	public User getThisUser(){
		thisUser=[Select Id, FirstName, Contact.Account.Name, Contact.AccountId from User Where Id = :userinfo.getUserId()];
		return thisUser;
	}
	
	public Account UserAccount = new Account();
	public Account getUserAccount(){
		UserAccount = [SELECT Id, Name, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode from Account where Id = :getThisUser().Contact.AccountId];
		return UserAccount;
	}

	public List<Royalty_Request__c> requests = new List<Royalty_Request__c>();
	public List<Royalty_Request__c> getRequests(){
		requests = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, Royalty_Expiration_Date__c, 
						Delivery_Mechanism__c, Estimated_Number_of_Users__c, Response_Due_Date__c, Misc_Comments__c, 
						Comments__c, Royalty_Amount__c, Parent_Request__r.Name from Royalty_Request__c where Account__r.Id = :getThisUser().Contact.AccountId AND Opportunity_Status__c='' Order By CreatedDate Desc];
		return requests;
	}
	
	public List<Royalty_Request__c> closedrequests = new List<Royalty_Request__c>();
	public List<Royalty_Request__c> getClosedRequests(){
        if (viewClosed == true){
        	closedrequests = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, Royalty_Expiration_Date__c, 
						Delivery_Mechanism__c, Estimated_Number_of_Users__c, Response_Due_Date__c, Misc_Comments__c, 
						Comments__c, Royalty_Amount__c, Opportunity_Status__c from Royalty_Request__c where Account__r.Id = :getThisUser().Contact.AccountId AND Opportunity_Status__c!='' Order By CreatedDate Desc];
            
        } else {
        	closedrequests = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, Royalty_Expiration_Date__c, 
						Delivery_Mechanism__c, Estimated_Number_of_Users__c, Response_Due_Date__c, Misc_Comments__c, 
						Comments__c, Royalty_Amount__c, Opportunity_Status__c from Royalty_Request__c where Account__r.Id = :getThisUser().Contact.AccountId AND Opportunity_Status__c!='' Order By CreatedDate Desc LIMIT 10];
            
        }
		return closedrequests;
	}

	public PageReference newRequest(){
    	PageReference callPage = new PageReference('/apex/CommRequestPage');
        return callPage;
    }
    
	public PageReference updateRequest(){
    	PageReference callPage = new PageReference('/apex/CommUpdateRequestPage?Id='+toSelect);
        return callPage;
    }
    
    public PageReference editRequest(){
    	PageReference callPage = new PageReference('/apex/CommRequestEdit?Id='+toSelect);
        return callPage;
    }    
    
    public PageReference saveNewRequest(){
    	newRequest.Account__c = getThisUser().Contact.AccountId;
    	insert newRequest;
    	
    	PageReference callPage = new PageReference('/apex/CommLandingPage');
        return callPage;
    }
    
    public PageReference backtoLandingPage(){
    	PageReference callPage = new PageReference('/apex/CommLandingPage');
        return callPage;
    }
    
    public PageReference saveEditedRequest(){
    	update requestupdate;
    	PageReference callPage = new PageReference('/apex/CommLandingPage');
    	return callPage;
    }
    
    public PageReference saveClonedRequest(){
    	requesttoclone.Parent_Request__c = System.currentPageReference().getParameters().get('Id');
    	insert requesttoclone;
    	PageReference callPage = new PageReference('/apex/CommLandingPage');
    	return callPage;
    }
    
    public Royalty_Request__c requesttoclone = new Royalty_Request__c();
	public Royalty_Request__c getRequestToClone(){
		Royalty_Request__c clonedrequest = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, Royalty_Expiration_Date__c, 
						Delivery_Mechanism__c, Estimated_Number_of_Users__c, Response_Due_Date__c, Misc_Comments__c, 
						Comments__c, Royalty_Amount__c from Royalty_Request__c where Id = :System.currentPageReference().getParameters().get('Id')];
		requesttoclone = new Royalty_Request__c(Community_Account__c=clonedrequest.Community_Account__c,Account_Street__c=clonedrequest.Account_Street__c,
						 Account__c = getThisUser().Contact.AccountId, Account_City__c=clonedrequest.Account_City__c, Account_Country__c=clonedrequest.Account_Country__c, Account_Postal_Code__c=clonedrequest.Account_Postal_Code__c,  
						Account_State__c=clonedrequest.Account_State__c, Number_of_Locations__c=clonedrequest.Number_of_Locations__c, Product_Mix__c=clonedrequest.Product_Mix__c, Existing_Revenue__c=clonedrequest.Existing_Revenue__c,  
						Delivery_Mechanism__c=clonedrequest.Delivery_Mechanism__c, Estimated_Number_of_Users__c=clonedrequest.Estimated_Number_of_Users__c);				
		return requesttoclone;
	}
	
    public PageReference cloneRequest(){
    	PageReference callPage = new PageReference('/apex/CommClonePage?Id='+toSelect);
    	return callPage;
    }
    
    public PageReference saveUpdatedRequest(){
    	if (requestupdate.ASTM_Product_Setup_Required__c == 'No'){
    		requestupdate.Contract_Start_Date__c = date.today();
    		requestupdate.Contract_End_Date__c = date.today().addYears(1);
    	}
    	update requestupdate;
    	
    	PageReference callPage;
    	if (requestupdate.IP_Address_Type__c == 'IP'){
    		callPage = new PageReference('/apex/CommAddIPsPage');
    	} else {
    		callPage = new PageReference('/apex/CommLandingPage');
    	}
        return callPage;
    }
    
    public PageReference saveIPs(){
    	
    	update requestupdate;
    	
    	if (!Test.isRunningTest()){
    		if (attachment.Body != null){
		    	attachment.OwnerId = UserInfo.getUserId();
		    	attachment.ParentId = requestupdate.Id; // the record the file is attached to
		    	attachment.IsPrivate = true;
		    	
		    	insert attachment;
    		}	
    	}
    	
    	PageReference callPage = new PageReference('/apex/CommLandingPage');
        return callPage;
    }
    
    public PageReference viewRequestDetail(){
        PageReference callPage = new PageReference('/apex/CommRequestView?Id='+toSelect);
        return callPage; 
    }
    
    public Royalty_Request__c thisrequest = new Royalty_Request__c();
    public Royalty_Request__c getThisRequest(){
    	if (toSelect != null){
    	thisrequest = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, 
						Delivery_Mechanism__c, Opportunity_Status__c, Comments__c, Response_Due_Date__c, Misc_Comments__c, 
						Estimated_Number_of_Users__c, Royalty_Amount__c from Royalty_Request__c where Id = :toSelect];
    	}
		return thisrequest;
    }
    
    public Royalty_Request__c requestupdate = new Royalty_Request__c();
    public Royalty_Request__c getRequestUpdate(){
    	requestupdate = [SELECT Id, Name, Community_Account__c, Account_Street__c, Account_City__c, Account_Country__c, Account_Postal_Code__c, Approval_Status__c, 
						CreatedDate, Account_State__c, Number_of_Locations__c, Product_Mix__c, Existing_Revenue__c, 
						Delivery_Mechanism__c, URL__c, Comments__c, Opportunity_Status__c, ASTM_Product_Setup_Required__c,
						IP_Address_Type__c, Contract_Start_Date__c, Contract_End_Date__c, IP_Addresses__c, Response_Due_Date__c, Misc_Comments__c, 
						Estimated_Number_of_Users__c, DRM_On_or_Off__c, Forced_Login__c, Watermark__c, Usage_Reports_Hidden__c,
						Counter_Subscription__c, Royalty_Expiration_Date__c, Industry_Tag__c from Royalty_Request__c where Id = :System.currentPageReference().getParameters().get('Id')];
		return requestupdate;
    }
    
    public static testMethod void validateCommunitiesController() {
		Account ca = new Account(Name='testaccount');
		insert ca;
		Contact ct = new Contact(FirstName='testcontact', LastName='testcontact', AccountId=ca.Id);
		insert ct;
		Profile p = [SELECT Id FROM Profile WHERE Name='Custom Partner Community User'];
	    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
	    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	    LocaleSidKey='en_US', ProfileId = p.Id, ContactId=ct.Id,
	    TimeZoneSidKey='America/Los_Angeles', UserName='testuser@astm.org',CommunityNickname = 'testUser123',
	    IsActive = true);
	    insert u;
	    Royalty_Request__c rr1 = new Royalty_Request__c(Community_Account__c='testaccount',Number_of_Locations__c=4,Delivery_Mechanism__c='Own Platform',Product_Mix__c='TBD',Account_Country__c='testcountry');
	    insert rr1;

	    PageReference pageRef = Page.CommLandingPage;
    	Test.setCurrentPageReference(pageRef);

	    Apexpages.StandardController stdController = new Apexpages.StandardController(rr1);

    	CommunitiesController controller = new CommunitiesController();
    		    
	    System.runAs(u) {
	    	System.debug('Current User: ' + UserInfo.getUserName());
	    	System.debug('Current Profile: ' + UserInfo.getProfileId());
	    	controller.getThisUser();

	    	controller.getRequests();
	    	controller.getClosedRequests();
	    	controller.newRequest();
	    	controller.updateRequest();
	    	controller.editRequest();
	    	controller.backtoLandingPage();
	    	controller.cloneRequest();
	    }
	    PageReference pageRef2 = Page.CommUpdateRequestPage;
    	pageRef2.getParameters().put('Id',rr1.Id);
    	Test.setCurrentPageReference(pageRef2);
    	controller.getRequestUpdate();
    	controller.requestupdate = rr1;
    	controller.saveUpdatedRequest();
	    controller.saveEditedRequest();
	    controller.saveIPs();
	    controller.viewRequestDetail();
	    controller.getRequestToClone();
	    controller.changeipReq();
	    controller.changeShowWon();
	    controller.changeSetupReq();
	    controller.saveClonedRequest();
	    controller.toSelect = String.valueOf(rr1.Id);
	    controller.getThisRequest();
        controller.viewClosed();
	    
	    controller = new CommunitiesController();
	    controller.requestupdate.IP_Address_Type__c = 'Applet';
	    controller.changeipReq();
	    controller.requestupdate.Opportunity_Status__c = 'Won';
	    controller.changeShowWon();
        controller.viewClosed = true;
        controller.getClosedRequests();
	    
	    controller = new CommunitiesController();
	    controller.requestupdate.IP_Address_Type__c = 'IP';
	    controller.changeipReq();
	    controller.requestupdate.ASTM_Product_Setup_Required__c = 'Yes';
	    controller.changeSetupReq();
	}
}