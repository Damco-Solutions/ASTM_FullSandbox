/**
 * Created by johnpernock from OpenGate Consulting on 2019-07-03.
 */

public without sharing class OppCOSComponentController {
    @AuraEnabled
    public static Id cloneOriginalOpp(Id recordId) {
        List<Opportunity> oppList = [
                SELECT Id, Name, LeadSource, Contract_Required__c, AccountId, StageName, CloseDate, Purchase_Order_Number__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
        ];
        if (oppList.size() > 0) {
            Opportunity opportunity = oppList[0];
            SObject originalSObject = (SObject) opportunity;
            List<SObject> originalSObjects = new List<SObject>{
                    originalSObject
            };
            List<SObject> clonedSObjects = SObjectAllFieldCloner.cloneObjects(
                    originalSObjects,
                    originalSObject.getSObjectType());
            Opportunity clonedOpportunity = (Opportunity) clonedSObjects.get(0);

            Integer cloneCount = 0;
            for (AggregateResult ar : [SELECT COUNT(Id) cnt FROM Opportunity WHERE Original_Opportunity__c = :recordId AND Change_of_Scope__c = TRUE]) {
                cloneCount = Integer.valueOf(ar.get('cnt'));
            }
            cloneCount++;
            clonedOpportunity.Type = 'Expansion on Existing Account';
            clonedOpportunity.Change_of_Scope__c = true;
            clonedOpportunity.Pricebook2Id = '01sC0000000DZcd';
            clonedOpportunity.Name = opportunity.Name + '-COS' + cloneCount;
            clonedOpportunity.StageName = opportunity.StageName;
            clonedOpportunity.CloseDate = opportunity.CloseDate;
            clonedOpportunity.AccountId = opportunity.AccountId;
            clonedOpportunity.LeadSource = opportunity.LeadSource;
            clonedOpportunity.Contract_Required__c = 'No';
            clonedOpportunity.Original_Opportunity__c = opportunity.Id;
            clonedOpportunity.Amount = 0;
            clonedOpportunity.Growth__c = 0;
            insert clonedOpportunity;
            return clonedOpportunity.Id;
        } else {
            return null;
        }
    }
}