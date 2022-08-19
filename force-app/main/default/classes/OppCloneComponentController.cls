/**
 * Created by johnpernock from OpenGate Consulting on 2019-07-03.
 */

public without sharing class OppCloneComponentController {
    @SuppressWarnings('ApexUnresolvableReference')
    @AuraEnabled
    public static CloneOppDetails getOppDetails(Id recordId) {
        CloneOppDetails returnOpp = new CloneOppDetails();
        // GetOpp
        List<Opportunity> oppFound = [
                SELECT Id, Number_of_LMS_Locations__c, Number_of_Locations_Sold__c, Contract_End_Date_automated__c,
                        AICC_or_LMS__c, AR_Invoice_Type__c, AccountId, Amount, Applet_URL__c, Are_IP_Addresses_Included__c,
                        Change_of_Scope__c, CloseDate, IsClosed, Contract_End_Date__c, Contract_Number_del__c, Contract_Required__c,
                        Contract_Start_Date_del__c, Counter_Subscription__c,CreatedById, CreatedDate, Custom_Settings__c, DRM__c,
                        Data_Quality_Description__c, Data_Quality_Score__c, Demo__c,Description, Estimated_of_LMS_Users__c,
                        Field_Suppression__c, Fiscal, FiscalQuarter, FiscalYear,ForecastCategoryName, ForecastCategory, Group_Admins__c,
                        Hide_Usage_Reports__c, IP_Addresses__c, Industry_Tag__c,LMS_Admin_Email__c, LMS_Admin_Name__c, LMS_Demo__c,
                        LMS_End_Date__c, LMS_Start_Date__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate,
                        LastViewedDate, LeadSource, Library_Builder_Admin__c, Library_Builder_Admin_Email__c, LID__LinkedIn_Company_Id__c,
                        Managed_vs_Non_Managed__c, Member_Dashboard_Domain__c, Name, NextStep, Notify_for_Renewal__c, Number_Of_Locations__c,
                        Number_Of_Potential_Locations__c, Original_Opportunity__c, OwnerId, Past_Due_Opportunity__c, Payment_Type__c,
                        Pricebook2Id, Probability, Opportunity_Type__c, Purchase_Order_Number__c, Registration_Form__c, Required_Log_In__c,
                        Shibboleth_Open_Athens_URL__c, Spec_Builder_Admin_Email__c, Spec_Builder_Admin_Name__c, StageName, Subscription_Code_Type__c,
                        Usage_Admin_Email__c,Usage_Admin_Name__c, Usage_Viewed_By__c, Watermark__c, RecordTypeId, RecordType.Name, Type, CampaignId,
                        IHS_Submit_for_Approval__c, Region__c, Regional_Approver__c, IHS_Approval__c, Oracle_Order_Number__c
   //                     Library_Builder_Admin2__c, Spec_Builder_Admin_Name2__c, LMS_Admin_Name2__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
        ];
//        if (oppFound.size() > 0){
//            Opportunity opp = oppFound[0];
//            System.debug(opp);
//            opp.Amount = opp.Amount.setScale(2);
//            returnOpp.opp = opp;
//        }
        returnOpp.opp = oppFound[0];
        //Get opportunity line items for the Opportunity and its child opportunities through the related contract
//        List<OpportunityLineItem> oppLinesFound = [SELECT Id, ServiceDate, Description, PricebookEntryId, ProductCode, Product2Id, Product2.Name, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :recordId];
        Map<Id, Opportunity> childOpportunitiesMap = new Map<Id, Opportunity>([
                SELECT Id
                FROM Opportunity
                WHERE Original_Opportunity__c = :recordId
                AND StageName = 'Closed Won'
        ]);
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(recordId);
        opportunityIds.addAll(childOpportunitiesMap.keySet());
        System.debug(childOpportunitiesMap.keySet());
//        List<OpportunityLineItem> opportunityLineItems = [
//                SELECT Id, ServiceDate, Description, PricebookEntryId, ProductCode, Product2Id, Product2.Name, Quantity, UnitPrice
//                FROM OpportunityLineItem
//                WHERE OpportunityId IN :opportunityIds
//        ];
//        System.debug(opportunityLineItems.size());

        //get a map of aggregate results by product2Id for the opportunity line items
        // use this to calculate the price of the consolidated item
        Map<Id, AggregateResult> countSumLineItemsByProduct2Id = new Map<Id, AggregateResult>();
        List<AggregateResult> productLineItems = [
                SELECT Product2Id product2Id, Product2.Name productName, SUM(UnitPrice) unitPriceSum, SUM(Quantity) quantity
                FROM OpportunityLineItem
                WHERE OpportunityId IN :opportunityIds
                GROUP BY Product2Id, Product2.Name
        ];
        for (AggregateResult aggregateResult : productLineItems) {
            Id aggId = (Id) aggregateResult.get('product2Id');
            if (!countSumLineItemsByProduct2Id.containsKey(aggId)) {
                countSumLineItemsByProduct2Id.put(aggId, aggregateResult);
            }
        }
        //get a map of PricebookEntryId by Product2Id for the pricebook of the cloned opportunity
        //use the PricebookEntryId from the Pricebook of the cloned opportunity
        List<PricebookEntry> pricebookEntries = [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Product2Id IN :countSumLineItemsByProduct2Id.keySet()
                AND Pricebook2Id = :oppFound[0].Pricebook2Id
        ];
        Map<Id, Id> priceBookEntryIdsByProduct2Id = new Map<Id, Id>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            if (!priceBookEntryIdsByProduct2Id.containsKey(pricebookEntry.Product2Id)) {
                priceBookEntryIdsByProduct2Id.put(pricebookEntry.Product2Id, pricebookEntry.Id);
            }
        }
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (Id id : countSumLineItemsByProduct2Id.keySet()) {
            AggregateResult currentResult = countSumLineItemsByProduct2Id.get(id);
            OpportunityLineItem newLineItem = new OpportunityLineItem(
                    Product2Id = id,
                    Description = (String) currentResult.get('productName'),
                    Quantity = (Decimal) currentResult.get('quantity'),
                    UnitPrice = (Decimal) currentResult.get('unitPriceSum') / (Decimal) currentResult.get('quantity'),
                    PricebookEntryId = priceBookEntryIdsByProduct2Id.get(id)
            );
            opportunityLineItems.add(newLineItem);
        }
        System.debug(opportunityLineItems);
        returnOpp.oppLines = opportunityLineItems.size() > 0 ? opportunityLineItems : null ;
        return returnOpp;
    }

    @AuraEnabled
    public static Id saveCloneOppData(String jsonOpp, String jsonLineItems, String jsonUpdatedFields, Decimal percentageIncrease) {
        Map<String, Object> updatedFields = (Map<String, Object>) JSON.deserializeUntyped(jsonUpdatedFields);
        Opportunity origOpp = (Opportunity) JSON.deserialize(jsonOpp, Opportunity.class);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        if (jsonLineItems != null && jsonLineItems != '') {
            lineItems = (List<OpportunityLineItem>) JSON.deserialize(jsonLineItems, List<OpportunityLineItem>.class);
        }
        Opportunity clonedOpp = origOpp.clone(false, false, true, false);
        //Update Fields from Update Field JSON
        clonedOpp.AccountId = (Id) updatedFields.get('AccountId');
        clonedOpp.OwnerId = (Id) updatedFields.get('OwnerId');
        clonedOpp.Name = (String) updatedFields.get('Name');
        clonedOpp.LeadSource = (String) updatedFields.get('LeadSource');
        clonedOpp.Description = (String) updatedFields.get('Description');
        clonedOpp.StageName = (String) updatedFields.get('StageName');
        clonedOpp.Probability = (Decimal) updatedFields.get('Probability');
        clonedOpp.CloseDate = Date.valueOf((String) updatedFields.get('CloseDate'));
        Object amt = updatedFields.get('Amount');
        try {
            Decimal amountField = (Decimal) amt;
            clonedOpp.Amount = amountField.setScale(2);
        } catch (Exception e) {
            clonedOpp.Amount = 0.0;
        }
        clonedOpp.Demo__c = (String) updatedFields.get('Demo__c');
        clonedOpp.Number_Of_Locations__c = (String) updatedFields.get('Number_Of_Locations__c');
        clonedOpp.Number_Of_Potential_Locations__c = (String) updatedFields.get('Number_Of_Potential_Locations__c');
        clonedOpp.Number_of_Locations_Sold__c = (String) updatedFields.get('Number_of_Locations_Sold__c');
        clonedOpp.Purchase_Order_Number__c = (String) updatedFields.get('Purchase_Order_Number__c');
        clonedOpp.Subscription_Code_Type__c = (String) updatedFields.get('Subscription_Code_Type__c');
        clonedOpp.Are_IP_Addresses_Included__c = (String) updatedFields.get('Are_IP_Addresses_Included__c');
        clonedOpp.AR_Invoice_Type__c = (String) updatedFields.get('AR_Invoice_Type__c');
        clonedOpp.Required_Log_In__c = (String) updatedFields.get('Required_Log_In__c');
        clonedOpp.Industry_Tag__c = (String) updatedFields.get('Industry_Tag__c');
        clonedOpp.Field_Suppression__c = (String) updatedFields.get('Field_Suppression__c');
        clonedOpp.Usage_Admin_Name__c = (String) updatedFields.get('Usage_Admin_Name__c');
        clonedOpp.Usage_Admin_Email__c = (String) updatedFields.get('Usage_Admin_Email__c');
        clonedOpp.Usage_Viewed_By__c = (String) updatedFields.get('Usage_Viewed_By__c');
        clonedOpp.Registration_Form__c = (String) updatedFields.get('Registration_Form__c');
        clonedOpp.IP_Addresses__c = (String) updatedFields.get('IP_Addresses__c');
        clonedOpp.Applet_URL__c = (String) updatedFields.get('Applet_URL__c');
        clonedOpp.Notify_for_Renewal__c = (String) updatedFields.get('Notify_for_Renewal__c');
        clonedOpp.Watermark__c = (String) updatedFields.get('Watermark__c');
        clonedOpp.Member_Dashboard_Domain__c = (String) updatedFields.get('Member_Dashboard_Domain__c');
        clonedOpp.DRM__c = (String) updatedFields.get('DRM__c');
        clonedOpp.Custom_Settings__c = (String) updatedFields.get('Custom_Settings__c');
        clonedOpp.Shibboleth_Open_Athens_URL__c = (String) updatedFields.get('Shibboleth_Open_Athens_URL__c');
        clonedOpp.Account_Street__c = (String) updatedFields.get('Account_Street__c'); //Modified By Damco to add Account Details
        clonedOpp.Community_Account__c = (String) updatedFields.get('Community_Account__c');
        clonedOpp.Account_City__c = (String) updatedFields.get('Account_City__c');
        clonedOpp.Account_State__c = (String) updatedFields.get('Account_State__c');
        clonedOpp.Account_Postal_Code__c = (String) updatedFields.get('Account_Postal_Code__c');
        clonedOpp.Account_Country__c = (String) updatedFields.get('Account_Country__c');
        clonedOpp.Existing_Revenue__c = (Decimal) updatedFields.get('Existing_Revenue__c'); //End 

        clonedOpp.Type = (String) updatedFields.get('Type');
        clonedOpp.Contract_Required__c = (String) updatedFields.get('Contract_Required__c');
        Object contractEndDate = updatedFields.get('Contract_End_Date__c');
        try {
            clonedOpp.Contract_End_Date__c = Date.valueOf((String) contractEndDate);
        } catch (Exception e) {
            clonedOpp.Contract_End_Date__c = null;
        }

        insert clonedOpp;
        System.debug(clonedOpp);
        List<OpportunityLineItem> clonedLineItems = new List<OpportunityLineItem>();
        for (OpportunityLineItem lineItem : lineItems) {
            OpportunityLineItem clonedItem = lineItem.clone(false, false, true, false);
            Decimal unitPrice = clonedItem.UnitPrice;
            Decimal updatedPrice = unitPrice * ((percentageIncrease / 100) + 1);
            clonedItem.UnitPrice = updatedPrice.setScale(2);
            clonedItem.OpportunityId = clonedOpp.Id;
            clonedLineItems.add(clonedItem);
        }
        insert clonedLineItems;
        return clonedOpp.Id;
    }

    public class CloneOppDetails {
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public List<OpportunityLineItem> oppLines;
        public CloneOppDetails() {
            opp = null;
            oppLines = new List<OpportunityLineItem>();
        }
    }
}