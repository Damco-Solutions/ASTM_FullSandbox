public with sharing class OrderFormControllerRoyalty {

    public Opportunity opportunity = new Opportunity();
    private Id ihsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHS').getRecordTypeId();
    private Id whiteLabelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('White_Label').getRecordTypeId();
    private Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ASTM').getRecordTypeId();
    public String oppId = ApexPages.currentPage().getParameters().get('Id');
    public Opportunity getOpportunity() {
        opportunity = [
                SELECT Id, Name, Type, Amount, Account.Name, Owner.Name, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode,
                        Account.BillingPostalCode, Account.BillingCountryCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode,
                        Account.ShippingPostalCode, Account.ShippingCountryCode, Account.Oracle_Account_Number__c, Purchase_Order_Number__c, IP_Address_Type__c,
                        Account_City__c, Account_Country__c, Community_Account__c, Account_Owner_Email__c, Account_Postal_Code__c, Account_State__c,
                        Account_Street__c, Approval_Date__c, Approval_Status__c, Comments__c, ASTM_Product_Setup_Required__c, Contract_Start_Date_del__c,
                        Contract_End_Date__c, Counter_Subscription__c, CreatedById, Delivery_Mechanism__c, DRM_On_or_Off__c, Estimated_Number_of_Users__c,
                        Existing_Revenue__c, Forced_Login__c, Industry_Tag__c, IP_Address__c, IP_Addresses__c, LastModifiedById, Number_Of_Locations__c,
                        Number_of_Standards__c, Payment_Date__c, Payment_Frequency__c, Product_Mix__c, Misc_Comments__c, Response_Due_Date__c,
                        Royalty_Amount__c, Royalty_Expiration_Date__c, Royalty_Payment__c, Sale_Type__c, URL__c, Usage_Reports_Hidden__c, Watermark__c, OwnerId, RecordTypeId
                FROM Opportunity
                WHERE Id = :oppId
//                WHERE Id = :System.currentPageReference().getParameters().get('Id')
        ];
        return opportunity;
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
        prods = [
                SELECT Id, Product2.ProductCode, Product2Id, Product2.Name, Product2.Description,
                        OpportunityId, TotalPrice
                FROM OpportunityLineItem
                WHERE OpportunityId = :oppId
        ];
        return prods;
    }

    public PageReference createOrder() {
        Id oid = Id.valueOf(oppId);

        Attachment att = new Attachment(Name = 'OrderFormRoyalty.xls');
        PageReference Order_page = new PageReference('/apex/OrderFormPageRoyalty');
        Order_page.getParameters().put('id', oppId);
        // return page content as blob type
        Blob content;
        if (Test.isRunningTest()) {
            content = Blob.valueOf('UNIT.TEST');
        } else {
            content = Order_page.getContent();
        }
        att.Body = content;
        att.ContentType = 'application/xls';
        //att.body = Order_page .getContent();
        // Associate with project's record Id
        att.ParentId = oppId;
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
    
                insert ContactForUser;
                
            
              if(getOpportunity().RecordTypeId == whiteLabelRecordTypeId){
                Case caseObj = new Case(
                ContactId = ContactForUser.id,
                Opportunity__c = getOpportunity().id,
                Subject = 'White Label Compass Order',
                OwnerId = SupportQueueId);

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

            insert caseObj;
            }
            else if(getOpportunity().RecordTypeId == astmRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactEmailToCheck[0].id,
                Opportunity__c = getOpportunity().id,
                Subject = 'ASTM Compass Order',
                OwnerId = SupportQueueId);

            insert caseObj; 
            }
            else if(getOpportunity().RecordTypeId == ihsRecordTypeId){
                Case caseObj = new Case(
                ContactId = contactEmailToCheck[0].id,
                Opportunity__c = getOpportunity().id,
                Subject = 'IHS Compass Order',
                OwnerId = SupportQueueId);

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
    public PageReference CallBothActions(){
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