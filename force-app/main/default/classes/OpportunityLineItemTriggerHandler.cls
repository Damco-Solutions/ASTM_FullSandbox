/**
 * Created by wmccu on 11/20/2020.
 */

public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    private Map<Id, OpportunityLineItem> oldOpportunityLineItemMap;
    private Map<Id, OpportunityLineItem> newOpportunityLineItemMap;
    private List<OpportunityLineItem> newOpportunityLineItemList;
    private List<OpportunityLineItem> oldOpportunityLineItemList;

    public OpportunityLineItemTriggerHandler() {
        this.oldOpportunityLineItemMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
        this.newOpportunityLineItemMap = (Map<Id, OpportunityLineItem>) Trigger.newMap;
        this.oldOpportunityLineItemList = (List<OpportunityLineItem>) Trigger.old;
        this.newOpportunityLineItemList = (List<OpportunityLineItem>) Trigger.new;
    }

    public override void afterInsert() {
        OpportunityLineItemActions.updateContractFromLineItems(getIdsFromList('OpportunityId', newOpportunityLineItemList));
    }
    public override void afterUpdate() {
        OpportunityLineItemActions.updateContractFromLineItems(getIdsFromList('OpportunityId', newOpportunityLineItemList));
    }
    public override void beforeDelete() {
        OpportunityLineItemActions.updateContractFromLineItems(getIdsFromList('OpportunityId', oldOpportunityLineItemList));
    }

    public static Set<Id> getIdsFromList(String fieldName, List<SObject> sobjectList) {
        Set<Id> ids = new Set<Id>();
        for (SObject currentRecord : sobjectList) {
            Id currentId = (Id) currentRecord.get(fieldName);
            if (!ids.contains(currentId)) {
                ids.add(currentId);
            }
        }
        return ids;
    }
}