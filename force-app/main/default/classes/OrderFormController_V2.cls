/**
 * Created by johnpernock from OpenGate Consulting on 2019-02-26.
 */
public without sharing class OrderFormController_V2 {
    public Opportunity opportunity = new Opportunity();
    public Opportunity getOpportunity() { return opportunity;}

    public OpportunityContactRole invoicecontact = new OpportunityContactRole();
    public OpportunityContactRole getInvoicecontact() {  return invoicecontact;}

    public OpportunityContactRole countercontact = new OpportunityContactRole();
    public OpportunityContactRole getCountercontact() {  return countercontact;}

    public OpportunityContactRole customerAccountAdmin = new OpportunityContactRole();
    public OpportunityContactRole getCustomerAccountAdmin(){ return customerAccountAdmin;}

    public Contract contract = new Contract();
    public Contract getContract(){ return contract;}

    public integer prodcount;
    public integer getProdCount(){ return prodcount;}

    public List<OpportunityLineItem> prods = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> getProds(){ return prods;}

    public OrderFormController_V2() {
        Id oid = (Id)ApexPages.currentPage().getParameters().get('id');
        System.debug(oid);
        try {
        opportunity = [SELECT Id, Name, Type, Account.Name, Owner.Name, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
                Account.BillingPostalCode, Account.BillingCountryCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode,
                Account.ShippingPostalCode, Account.ShippingCountryCode, Account.Oracle_Account_Number__c, Purchase_Order_Number__c,
                Managed_vs_Non_Managed_Picklist__c, Subscription_Code_Type__c, Are_IP_Addresses_Included__c, Was_Sales_Tax_calculated_in_the_form__c,
                DRM__c, Required_Log_In__c, Watermark__c, Hide_Usage_Reports__c, Counter_Subscription__c, Description,
                AR_Invoice_Type__c, Number_of_LMS_Locations__c, AICC_or_LMS__c, Demo__c, Estimated_of_LMS_Users__c,
                LMS_Admin_Email__c, LMS_Admin_Name__r.Name, LMS_Admin_Name__c, LMS_Demo__c, LMS_End_Date__c, LMS_Start_Date__c,
                Reseller_Consortium__c, SpecBuilder_One__c, SpecBuilder2__c, SpecBuilder3__c, SpecBuilder4__c, Contract_Required__c,
                SpecBuilder5__c, Pricebook2.Name, Applet_URL__c, Customized_Return_Email_Address__c, Registration_Form__c,
                Field_Suppression__c, Group_Admins__c, Industry_Tag__c, IP_Addresses__c, Library_Builder_Admin__c, Library_Builder_Admin_Email__c,
                Member_Dashboard_Domain__c, Shibboleth_Open_Athens_URL__c, Payment_Type__c, CloseDate, Notify_for_Renewal__c,
                Spec_Builder_Admin_Email__c, Spec_Builder_Admin_Name__c, Usage_Admin_Email__c, Usage_Admin_Name__c, Usage_Viewed_By__c FROM Opportunity WHERE Id = :oid];
        }catch(Exception e){ System.debug(e);}
        System.debug(opportunity);
        try {
            invoicecontact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :oid AND Role = 'Invoice Contact'];
        }catch(Exception e){ System.debug(e);}
        System.debug(invoicecontact);
        try {
            countercontact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :oid AND Role = 'Counter'];
        }catch(Exception e){ System.debug(e);}
        System.debug(countercontact);
        try {
            customerAccountAdmin = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :oid AND Role = 'Customer Account Admin'];
        }catch(Exception e){ System.debug(e);}
        System.debug(customerAccountAdmin);
        try {
            contract = [SELECT Id, Name, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :oid];
        }catch(Exception e){ System.debug(e);}
        System.debug(contract);
        try {
            prodcount = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :oid];
        }catch(Exception e){ System.debug(e);}
        System.debug(prodcount);
        try {
            prods = [SELECT Id, Product2.ProductCode, Product2Id, Product2.Name, Product2.Description, OpportunityId, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oid];
        }catch(Exception e){ System.debug(e);}
        System.debug(prods);
    }
}