global with sharing class OrderFormController_Skuid {
    public static Opportunity opportunity = new Opportunity();
    public static Opportunity getOpportunity(Id oppId){
        opportunity = [SELECT Id, Name, Type, Account.Name, Owner.Name, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, 
            Account.BillingPostalCode, Account.BillingCountryCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, 
            Account.ShippingPostalCode, Account.ShippingCountryCode, Account.Oracle_Account_Number__c, Purchase_Order_Number__c,
                Managed_vs_Non_Managed_Picklist__c, Subscription_Code_Type__c, Are_IP_Addresses_Included__c, Was_Sales_Tax_calculated_in_the_form__c,
            DRM__c, Required_Log_In__c, Watermark__c, Hide_Usage_Reports__c, Counter_Subscription__c, Description,
            AR_Invoice_Type__c, Number_of_LMS_Locations__c, AICC_or_LMS__c, Demo__c, Estimated_of_LMS_Users__c, 
            LMS_Admin_Email__c, LMS_Admin_Name__r.Name, LMS_Admin_Name__c, LMS_Demo__c, LMS_End_Date__c, LMS_Start_Date__c, 
            SpecBuilder_One__c, SpecBuilder2__c, SpecBuilder3__c, SpecBuilder4__c, Contract_Required__c,
            SpecBuilder5__c, Pricebook2.Name, Applet_URL__c, Customized_Return_Email_Address__c, Registration_Form__c,
            Field_Suppression__c, Group_Admins__c, Industry_Tag__c, IP_Addresses__c, Library_Builder_Admin__c, Library_Builder_Admin_Email__c,
            Member_Dashboard_Domain__c, Shibboleth_Open_Athens_URL__c, Payment_Type__c, CloseDate, Notify_for_Renewal__c,
            Spec_Builder_Admin_Email__c, Spec_Builder_Admin_Name__c, Usage_Admin_Email__c, Usage_Admin_Name__c, Usage_Viewed_By__c FROM Opportunity WHERE Id = :oppId];
        return opportunity;
    }
    
    public static OpportunityContactRole invoiceContact = new OpportunityContactRole();
    public static OpportunityContactRole getInvoiceContact(){
        try{
            invoiceContact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Invoice Contact'];
        } catch (Exception e){
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }
        
        return invoiceContact;
    }
    
    public static OpportunityContactRole counterContact = new OpportunityContactRole();
    public static OpportunityContactRole getCounterContact(){
        try{
            counterContact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Counter'];
        } catch (Exception e){
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }
        
        return counterContact;
    }
    
    public static OpportunityContactRole customerAccountAdmin = new OpportunityContactRole();
    public static OpportunityContactRole getCustomerAccountAdmin(){
        try{
            customerAccountAdmin = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Customer Account Admin'];
        } catch (Exception e){
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }
        
        return customerAccountAdmin;
    }
    
    public static Contract contract = new Contract();
    public static Contract getContract(){
        contract = [SELECT Id, Name, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :opportunity.Id];
        return contract;
    }
    
    public static Integer prodCount;
    public static Integer getProdCount(){
        prodCount = [ SELECT COUNT()
                    FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id ];
        return prodCount;
    }
    public static List<OpportunityLineItem> prods = new List<OpportunityLineItem>();
    public static List<OpportunityLineItem> getProds(){
        prods = [SELECT Id, Product2.ProductCode, Product2Id, Product2.Name, Product2.Description, OpportunityId, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
        return prods;
    }
    
    public static void createSkuidOrder(Id oppId){
        Id oid =getOpportunity(oppId).Id;
        getProds();
        getContract();
        getProdCount();
        getInvoiceContact();
        getCounterContact();
        getCustomerAccountAdmin();
        
        Attachment att = new Attachment(Name = 'orderform.xls');
        PageReference Order_page = new PageReference('/apex/OrderFormPage2');
        Order_page .getParameters().put('id',getOpportunity(oppId).Id);
        // return page content as blob type
        //att.body = PO_page .getContentAsPDF();
        //tested below to create .doc, need to change file name ext. too
        Blob content;
        if (Test.isRunningTest()){
        content=Blob.valueOf('UNIT.TEST');
        } else {
        content= Order_page .getContent();
        }
        att.Body = content;
        att.ContentType = 'application/xls';
        //att.body = Order_page .getContent();
        // Associate with project's record Id
        att.ParentId = getOpportunity(oppId).Id;
        insert att; 
    }
    
    @InvocableMethod(Label='CreateOrderForm' Description='')
    global static List<Boolean> OrderFormCreate (List<OrderFormRequest> requests) {
        List<Boolean> results = new List<Boolean>();
        try{
            createSkuidOrder(requests[0].oppId);
            results.add(true);
        }catch (Exception e) {
            results.add(false);
        }
        return results;

    }

    global class OrderFormRequest {
        @InvocableVariable(Required=true)
        public String oppId;
    }
}