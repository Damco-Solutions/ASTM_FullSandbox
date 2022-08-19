/**
 * Created by wmccu on 11/20/2020.
 */

public without sharing class OpportunityLineItemActions {
    @Future
    public static void updateContractFromLineItems(Set<Id> opportunityIds) {
        //get all opportunity ids related to the contract for the opportunity
        List<Opportunity> opportunitiesWithContractId = [
                SELECT Id, ContractId
                FROM Opportunity
                WHERE Id = :opportunityIds
                AND ContractId != NULL
        ];
        Set<Id> contractIds = OpportunityLineItemTriggerHandler.getIdsFromList('ContractId', opportunitiesWithContractId);
        //get opportunities and related line items
        List<Opportunity> opportunities = [
                SELECT Id, ContractId, (SELECT Id, Product2.Name, TotalPrice FROM OpportunityLineItems)
                FROM Opportunity
                WHERE ContractId = :contractIds
        ];
        //build a map of opportunities by contract id for processing
        Map<Id, List<Opportunity>> opportunitiesByContractId = new Map<Id, List<Opportunity>>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.ContractId != null) {
                Id currentContractId = opportunity.ContractId;
                if (opportunitiesByContractId.containsKey(currentContractId)) {
                    List<Opportunity> currentOpportunities = opportunitiesByContractId.get(currentContractId);
                    currentOpportunities.add(opportunity);
                    opportunitiesByContractId.put(currentContractId, currentOpportunities);
                } else {
                    List<Opportunity> newOpportunities = new List<Opportunity>();
                    newOpportunities.add(opportunity);
                    opportunitiesByContractId.put(opportunity.ContractId, newOpportunities);
                }
            }
        }
        List<Contract> contracts = new List<Contract>();
        //loop over contract ids and get the product string and renewal amount
        for (Id id : opportunitiesByContractId.keySet()) {
            Decimal renewalAmount = 0;
            Set<String> productSet = new Set<String>();
            for (Opportunity opportunity : opportunitiesByContractId.get(id)) {
                for (OpportunityLineItem opportunityLineItem : opportunity.OpportunityLineItems) {
                    if (!productSet.contains(opportunityLineItem.Product2.Name)) {
                        productSet.add(opportunityLineItem.Product2.Name);
                    }
                    renewalAmount += opportunityLineItem.TotalPrice;
                }
            }
            Contract contractUpdate = new Contract(
                    Id = id,
                    Products__c = productSet.size() > 0 ? String.join(new List<String>(productSet), ', ') : '',
                    Contract_Renewal_Amount__c = renewalAmount
            );
            contracts.add(contractUpdate);
        }
        if (contracts.size() > 0) {
            update contracts;
        }
    }
}