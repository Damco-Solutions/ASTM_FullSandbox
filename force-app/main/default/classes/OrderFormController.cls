//public with sharing class OrderFormController {
public with sharing class OrderFormController {
    public Opportunity opportunity = new Opportunity();

    private Id ihsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHS').getRecordTypeId();
    private Id whiteLabelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('White_Label').getRecordTypeId();
    private Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ASTM').getRecordTypeId();
    public Opportunity getOpportunity() {
        opportunity = [
                SELECT Id, Amount, Name, Type, Account.Name, Owner.Name, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
                        Account.BillingPostalCode, Account.BillingCountryCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode,
                        Account.ShippingPostalCode, Account.ShippingCountryCode, Account.Oracle_Account_Number__c, Purchase_Order_Number__c,
                        Managed_vs_Non_Managed_Picklist__c, Subscription_Code_Type__c, Are_IP_Addresses_Included__c, Was_Sales_Tax_calculated_in_the_form__c,
                        DRM__c, Required_Log_In__c, Watermark__c, Hide_Usage_Reports__c, Counter_Subscription__c, Description,
                        AR_Invoice_Type__c, Number_of_LMS_Locations__c, AICC_or_LMS__c, Demo__c, Estimated_of_LMS_Users__c,
                        LMS_Admin_Email__c, LMS_Demo__c, LMS_End_Date__c, LMS_Start_Date__c,
                        SpecBuilder_One__c, SpecBuilder2__c, SpecBuilder3__c, SpecBuilder4__c, Contract_Required__c,
                        SpecBuilder5__c, Pricebook2.Name, Applet_URL__c, Customized_Return_Email_Address__c, Registration_Form__c,
                        Field_Suppression__c, Group_Admins__c, Industry_Tag__c, IP_Addresses__c, Library_Builder_Admin__c, Library_Builder_Admin_Email__c,
                        Member_Dashboard_Domain__c, Shibboleth_Open_Athens_URL__c, Payment_Type__c, CloseDate, Notify_for_Renewal__c,
                        Spec_Builder_Admin_Email__c, Spec_Builder_Admin_Name__c, Usage_Admin_Email__c, Usage_Admin_Name__c, Usage_Viewed_By__c, Original_Opportunity__c,
                        Change_of_Scope__c, OwnerId, RecordTypeId, LMS_Admin_Name__r.Name, LMS_Admin_Name__c
//                        Spec_Builder_Admin_Name2__c, Spec_Builder_Admin_Name2__r.Name, LMS_Admin_Name2__r.Name, LMS_Admin_Name2__c, Library_Builder_Admin2__c,
//                        Library_Builder_Admin2__r.Email, Library_Builder_Admin2__r.Name, LMS_Admin_Name2__r.Email, Spec_Builder_Admin_Name2__r.Email
                FROM Opportunity
                WHERE Id = :System.currentPageReference().getParameters().get('Id')
        ];
        return opportunity;
    }

    public OpportunityContactRole invoiceContact = getInvoiceContact();
    public OpportunityContactRole getInvoiceContact() {
        try {
            invoiceContact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Invoice Contact'];
        } catch (Exception e) {
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }

        return invoiceContact;
    }

    public OpportunityContactRole counterContact = new OpportunityContactRole();
    public OpportunityContactRole getCounterContact() {
        try {
            counterContact = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Counter'];
        } catch (Exception e) {
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }

        return counterContact;
    }

    public OpportunityContactRole customerAccountAdmin = new OpportunityContactRole();
    public OpportunityContactRole getCustomerAccountAdmin() {
        try {
            customerAccountAdmin = [SELECT Id, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND Role = 'Customer Account Admin'];
        } catch (Exception e) {
            //opportunity.addError('There is no Invoice Contact for this opportunity.');
        }

        return customerAccountAdmin;
    }

    public Contract contract = new Contract();
    public Contract getContract() {
        if (opportunity.Change_of_Scope__c == true) {
            contract = [SELECT Id, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :opportunity.Original_Opportunity__c ORDER BY CreatedDate DESC LIMIT 1];

        } else {
            contract = [SELECT Id, StartDate, EndDate FROM Contract WHERE Related_Opportunity__c = :opportunity.Id ORDER BY CreatedDate DESC LIMIT 1];
        }
        return contract;
    }

    public Integer productionCount;
    public Integer getProdCount() {
        productionCount = [
                SELECT COUNT()
                FROM OpportunityLineItem
                WHERE OpportunityId = :getOpportunity().Id
        ];
        return productionCount;
    }
    public List<OpportunityLineItem> prods = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> getProds() {
        prods = [SELECT Id, Product2.ProductCode, Product2Id, Product2.Name, Product2.Description, OpportunityId, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :getOpportunity().Id];
        return prods;
    }

    public PageReference createOrder() {
        Id oid = getOpportunity().Id;

        Attachment att = new Attachment(Name = 'orderform.xls');
        PageReference Order_page = new PageReference('/apex/OrderFormPage2');
        Order_page.getParameters().put('id', getOpportunity().Id);
        // return page content as blob type
        //att.body = PO_page .getContentAsPDF();
        //tested below to create .doc, need to change file name ext. too
        Blob content;
        if (Test.isRunningTest()) {
            content = Blob.valueOf('UNIT.TEST');
        } else {
            content = Order_page.getContent();
        }
        att.Body = content;
        att.ContentType = 'application/xls';
        att.OwnerId = UserInfo.getUserId();
        att.Description = 'test';
        //att.body = Order_page .getContent();
        // Associate with project's record Id
        att.ParentId = getOpportunity().Id;
        insert att;

        PageReference callPage = new PageReference('/' + oid);
        return callPage;
    }
/*
    public Pagereference CreateCase(){
        Id oid = getOpportunity().Id;
        OrderFormControllerSettings__c CS = OrderFormControllerSettings__c.getInstance();
        Id BucketAccountId = Id.valueOf(CS.ASTM_Bucket_Account__c);
        Id SupportQueueId = Id.valueOf(CS.Support_Queue_Id__c);

        

        Id userId = getOpportunity().OwnerId;
        User contactToMatch = [select ContactId,Email,FirstName,LastName from user where id = :userid];
        List <Contact> contactEmailToCheck =[select id, email from contact where email = :contactToMatch.Email];
        System.debug(contactToMatch);
        System.debug(contactToMatch.ContactId);
        System.debug(contactToMatch.ContactId == null);
        
        System.debug(contactEmailToCheck);
//user does not have contactId field filled AND no contacts found with user.email
        if(contactToMatch.ContactId == null && contactEmailToCheck.size() == 0){
            
                Contact ContactForUser = new Contact(
                    AccountId = BucketAccountId,
                    Email = contactToMatch.email,
                    FirstName = contactToMatch.FirstName,
                    LastName = contactToMatch.LastName);
//ASTM Bucket account (PROD) 2F500C000000b6iUsIAI NEED TO CONFIRM
                insert ContactForUser;
                
            
              if(getOpportunity().RecordTypeId == whiteLabelRecordTypeId){
                Case caseObj = new Case(
                ContactId = ContactForUser.id,
                Opportunity__c = getOpportunity().id,
                Subject = 'White Label Compass Order',
                OwnerId = SupportQueueId);
//Support queue ID (PROD) 00G3c000003XIwYEAW

            insert caseObj;
            }
            else if(getOpportunity().RecordTypeId == astmRecordTypeId){
                Case caseObj = new Case(
                ContactId = ContactForUser.id,
                Opportunity__c = getOpportunity().id,
                Subject = 'ASTM Compass Order',
                OwnerId = SupportQueueId);

            insert caseObj; 
            }
            else if(getOpportunity().RecordTypeId == ihsRecordTypeId){
                Case caseObj = new Case(
                ContactId = ContactForUser.id,
                Opportunity__c = getOpportunity().id,
                Subject = 'IHS Compass Order',
                OwnerId = SupportQueueId);

            insert caseObj; 
            }

        }
//user does not have contactId field filled AND contact(s) ARE found with user.email
        else if(contactToMatch.ContactId == null && contactEmailToCheck.size() >0){

        if(getOpportunity().RecordTypeId == whiteLabelRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactEmailToCheck[0].id,
                Opportunity__c = getOpportunity().id,
                Subject = 'White Label Compass Order',
                OwnerId = SupportQueueId);
//White Label Record Type ID (PROD) 0123c0000008CrfAAE
            insert caseObj;
            }
            else if(getOpportunity().RecordTypeId == astmRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactEmailToCheck[0].id,
                Opportunity__c = getOpportunity().id,
                Subject = 'ASTM Compass Order',
                OwnerId = SupportQueueId);
//ASTM Record Type ID (PROD) 0123c000000GeZ1AAK
            insert caseObj; 
            }
            else if(getOpportunity().RecordTypeId == ihsRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactEmailToCheck[0].id,
                Opportunity__c = getOpportunity().id,
                Subject = 'IHS Compass Order',
                OwnerId = SupportQueueId);
//IHS Record Type ID (PROD) 0123c0000007yUEAAY
            insert caseObj; 
            }
    }
//user DOES have contactId field filled

        else if(contactToMatch.ContactId != null){
        

            if(getOpportunity().RecordTypeId == whiteLabelRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactToMatch.ContactId,
                Opportunity__c = getOpportunity().id,
                Subject = 'White Label Compass Order',
                OwnerId = SupportQueueId);

                insert caseObj;
            }
            else if(getOpportunity().RecordTypeId == astmRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactToMatch.ContactId,
                Opportunity__c = getOpportunity().id,
                Subject = 'ASTM Compass Order',
                OwnerId = SupportQueueId);

                insert caseObj; 
            }
            else if(getOpportunity().RecordTypeId == ihsRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactToMatch.ContactId,
                Opportunity__c = getOpportunity().id,
                Subject = 'IHS Compass Order',
                OwnerId = SupportQueueId);

            insert caseObj; 
            }
        }
    
        PageReference callPage = new PageReference('/' + oid);
        return callPage;
    
    }
    */
    public PageReference CallBothActions() {

        Id oid = getOpportunity().Id;
        createOrder();
        /*
        if(getOpportunity().RecordTypeId == whiteLabelRecordTypeId ||  getOpportunity().RecordTypeId == astmRecordTypeId || getOpportunity().RecordTypeId == ihsRecordTypeId){
        CreateCase();
        }
        */
        PageReference callPage = new PageReference('/' + oid);
        return callPage;
    }

}