/**
 * Created by johnpernock from OpenGate Consulting on 12/12/18.
 */

trigger LeadTrigger on Lead (before insert, before update) {
    if(Trigger.isBefore){
        if (Trigger.isInsert){
            for (Lead lead : Trigger.new){
                System.debug(lead.LeadSource);
                System.debug(lead.Lead_Source__c);
                if (lead.LeadSource == null){
                    lead.LeadSource = lead.Lead_Source__c;
                }else if (lead.Lead_Source__c == null) {
                    lead.Lead_Source__c = lead.LeadSource;
                }
            }
        }else if(Trigger.isUpdate){
            for (Lead lead : Trigger.new){
                Lead oldLead = Trigger.oldMap.get(lead.Id);
                if (lead.LeadSource != oldLead.LeadSource){
                    lead.Lead_Source__c = lead.LeadSource;
                }else if (lead.Lead_Source__c != oldLead.Lead_Source__c){
                    lead.LeadSource = lead.Lead_Source__c;
                }
            }
        }
    }
}