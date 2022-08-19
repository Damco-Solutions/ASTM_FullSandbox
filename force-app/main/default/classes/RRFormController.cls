public with sharing class RRFormController {

	public Royalty_Request__c r_request = new Royalty_Request__c();
	public Royalty_Request__c getR_Request(){
		r_request = [SELECT Id, Name, Account__r.Name, Response_Due_Date__c, 
		Approval_Status__c, Opportunity_Status__c, Comments__c, Delivery_Mechanism__c, ASTM_Product_Setup_Required__c,
		IP_Address_Type__c, URL__c, IP_Addresses__c, Parent_Request__r.Name, DRM_On_or_Off__c, Forced_Login__c,
		Watermark__c, Usage_Reports_Hidden__c, Counter_Subscription__c, Royalty_Amount__c, Royalty_Expiration_Date__c,
		Existing_Revenue__c, Number_of_Locations__c, Product_Mix__c, Estimated_Number_of_Users__c, Misc_Comments__c,
		Contract_Start_Date__c, Contract_End_Date__c, Account_Street__c, Account_City__c,
		Account_State__c, Account_Postal_Code__c, Account_Country__c from Royalty_Request__c where Id = :System.currentPageReference().getParameters().get('Id')];
		return r_request;
	}

	public PageReference createRR(){ 
        Id rid =getR_Request().Id;
        
        Attachment att = new Attachment(name = 'resellerorder.xls');
        PageReference RR_page = new PageReference('/apex/RRFormPage_new');
        RR_page .getParameters().put('id',getR_Request().Id);
        // return page content as blob type
        //att.body = PO_page .getContentAsPDF();
        //tested below to create .doc, need to change file name ext. too
        Blob content;
		if (Test.IsRunningTest()){
		content=Blob.valueOf('UNIT.TEST');
		} else {
        content= RR_page .getContent();
   		}
        att.body = content;
        att.ContentType = 'application/xls';
        //att.body = Order_page .getContent();
        // Associate with project's record Id
        att.parentid = getR_Request().Id;
        insert att;
    
        PageReference callPage = new PageReference('/'+rid);
        return callPage;  
    }
}