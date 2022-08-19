/**
 * Created by johnpernock from OpenGate Consulting on 2019-03-26.
 */

global class CloneChildOppsBatch implements Database.Batchable<sObject> {
    private String accountId;

    public CloneChildOppsBatch(Id acctId) {
        accountId = acctId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,ParentId,(SELECT id,isdeleted,accountid,RecordTypeId,isprivate,name,description,stagename,amount,probability,expectedrevenue,totalopportunityquantity,closedate,type,nextstep,leadsource,isclosed,iswon,forecastcategory,forecastcategoryname,campaignid,hasopportunitylineitem,pricebook2id,ownerid,createddate,createdbyid,lastmodifieddate,lastmodifiedbyid,systemmodstamp,lastactivitydate,fiscalquarter,fiscalyear,fiscal,lastvieweddate,lastreferenceddate,partneraccountid,syncedquoteid,contractid,hasopenactivity,hasoverduetask,data_quality_description__c,data_quality_score__c,number_of_locations__c,number_of_potential_locations__c,contract_required__c,contract_start_date_del__c,contract_end_date__c,contract_number_del__c,opportunity_type__c,total_account_growth_value__c,past_due_opportunity__c,lost__c,managed_vs_non_managed__c,Managed_vs_Non_Managed_Picklist__c,required_log_in__c,drm__c,watermark__c,hide_usage_reports__c,purchase_order_number__c,subscription_code_type__c,are_ip_addresses_included__c,was_sales_tax_calculated_in_the_form__c,counter_subscription__c,payment_type__c,original_opportunity__c,change_of_scope__c,aicc_or_lms__c,ar_invoice_type__c,demo__c,estimated_of_lms_users__c,lms_admin_email__c,lms_admin_name__c,lms_demo__c,lms_end_date__c,lms_start_date__c,number_of_lms_locations__c,reseller_consortium__c,specbuilder2__c,specbuilder3__c,specbuilder4__c,specbuilder5__c,specbuilder_one__c,applet_url__c,custom_settings__c,customized_return_email_address__c,field_suppression__c,group_admins__c,ip_addresses__c,industry_tag__c,library_builder_admin_email__c,library_builder_admin__c,member_dashboard_domain__c,notify_for_renewal__c,shibboleth_open_athens_url__c,spec_builder_admin_email__c,spec_builder_admin_name__c,usage_admin_email__c,usage_admin_name__c,usage_viewed_by__c,registration_form__c,pricebook__c,approved__c,oracle_order_number__c,john_pace_approval__c,created_from_lead__c FROM Opportunities WHERE Change_of_Scope__c = false ORDER BY CloseDate DESC, CreatedDate DESC LIMIT 1) FROM Account WHERE ParentId = \'' + accountId + '\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> childAccounts) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> clonedOppIds = new Set<Id>();
        for (Account acct : childAccounts){ for (Opportunity acctOpp : acct.Opportunities){ System.debug(acctOpp); if (!oppIds.contains(acctOpp.Id)){ oppIds.add(acctOpp.Id);}}}
        List<Opportunity> COSOpps = [SELECT id,Original_Opportunity__c,(SELECT Id, Product2Id, UnitPrice, Quantity, OpportunityId FROM OpportunityLineItems) FROM Opportunity WHERE Change_of_Scope__c = true AND Original_Opportunity__c =: oppIds];
        Map<Id, Opportunity> childAcctOppProducts = new Map<ID, Opportunity>([SELECT Id, Name, (SELECT Id, Product2Id, UnitPrice, Quantity, OpportunityId FROM OpportunityLineItems)FROM Opportunity WHERE Id =: oppIds]);
        List<OpportunityContactRole> oppContactRoles = [SELECT Id, ContactId, Role, IsPrimary, OpportunityId FROM OpportunityContactRole WHERE OpportunityId =: oppIds];
            for (Account acct : childAccounts) {
                System.debug(acct.Opportunities.size());
                for (Opportunity acctOpp : acct.Opportunities) {
                    System.debug(acctOpp.Name);
                    Opportunity oppLineData = childAcctOppProducts.get(acctOpp.Id);
                    List<OpportunityLineItem> lineItems = oppLineData.OpportunityLineItems;
                    Opportunity clonedParent = acctOpp.clone(false, true, false, false);
                    if(clonedParent.Name.length() > 110){
                        clonedParent.Name = clonedParent.Name.substring(0, 110) + '-Renewal';
                    }else{
                        clonedParent.Name = clonedParent.Name +  '-Renewal';
                    }
                    clonedParent.Contract_Required__c = 'Yes';
                    clonedParent.CloseDate = acctOpp.CloseDate.addYears(1);
                    clonedParent.StageName = 'Closed Won';
                    clonedParent.Type = 'Renewal';
                    clonedParent.Amount = 0.0;
                    System.debug(clonedParent);
                    insert  clonedParent;
                    List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
                    for (OpportunityLineItem lineItem : lineItems){
                        OpportunityLineItem clonedLine = lineItem.clone(false, true, false, false);
                        clonedLine.OpportunityId = clonedParent.Id;
                        newLineItems.add(clonedLine);
                    }
                    List<OpportunityContactRole> newContactRoles = new List<OpportunityContactRole>();
                    for (OpportunityContactRole contactRole : oppContactRoles){
                        if (contactRole.OpportunityId == acctOpp.Id){
                            OpportunityContactRole role = contactRole.clone(false, true, false, false);
                            role.OpportunityId = clonedParent.Id;
                            newContactRoles.add(role);
                        }
                    }
                    insert newContactRoles;
                    for (Opportunity cosOpp : COSOpps){
                        if (cosOpp.Original_Opportunity__c == acctOpp.Id){
                            List<OpportunityLineItem> coslineItems = cosOpp.OpportunityLineItems;
                            for (OpportunityLineItem cosLine : coslineItems){
                                Boolean currentExist = false;
                                for (OpportunityLineItem clonedLine : newLineItems){ if (clonedLine.Product2Id == cosLine.Product2Id){ currentExist = true;}}
                                if (!currentExist){
                                    OpportunityLineItem clonedCOSLine = cosLine.clone(false, true, false, false);
                                    clonedCOSLine.OpportunityId = clonedParent.Id;
                                    newLineItems.add(clonedCOSLine);
                                }else{
                                    for (OpportunityLineItem clonedLine : newLineItems){
                                        if (clonedLine.Product2Id == cosLine.Product2Id) {
                                            clonedLine.Quantity += cosLine.Quantity;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    insert newLineItems;
                    if (!clonedOppIds.contains(clonedParent.Id)) {
                        clonedOppIds.add(clonedParent.Id);
                    }
                }
            }
            System.enqueueJob(new CloneChildOrderFormQueueable(clonedOppIds));
    }

    global void finish(Database.BatchableContext BC) {
        List<User> currUserList = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if (currUserList.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{currUserList[0].email});
            mail.setReplyTo(currUserList[0].email);
            mail.setSenderDisplayName('Clone Opps Batch Processing');
            mail.setSubject('Clone Opps Batch Process Completed');
            mail.setPlainTextBody('Clone Opps Batch Process Completed');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }

//    public static void createOrderForms(String ids){
//        System.debug(ids);
//        Set<Id> clonedIds = (Set<Id>)JSON.deserialize(ids, Set<Id>.class);
//        System.debug(clonedIds);
//        for (Id oppId : clonedIds){
//            Attachment att = new Attachment(Name = 'orderform.xls');
//            PageReference Order_page = new PageReference('/apex/OrderFormPage_V2');
//            Order_page.getParameters().put('id',oppId);
//            Blob content;
//            if (Test.isRunningTest()){ content=Blob.valueOf('UNIT.TEST');} else { content= Order_page.getContent();}
//            att.Body = content;
//            att.ParentId = oppId;
//            insert att;
//        }
//    }
}