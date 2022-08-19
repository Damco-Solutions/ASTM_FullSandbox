trigger UpdateContractProducts on OpportunityLineItem (before insert) {
    //TODO delete this trigger
//	if (trigger.isInsert || trigger.isUpdate){
//		Map<Id, OpportunityLineItem> oppOLIsMap
//                    = new Map<Id, OpportunityLineItem>([SELECT Id, Opportunity.Contract_Required__c,Opportunity.Amount
//                                                    FROM OpportunityLineItem
//                                                    WHERE Id IN :Trigger.New]);
//
//		Set<Id> oppIds = new Set<Id>();
//		for(OpportunityLineItem oli : Trigger.new){
//			if(!oppIds.contains(oli.OpportunityId)){
//				oppIds.add(oli.OpportunityId);
//			}
//		}
//		List<Contract> oppContracts = new List<Contract>([Select Id, Products__c, Related_Opportunity__c From Contract WHERE Related_Opportunity__c IN :oppIds]);
//		List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>([Select Product2.Name, Product2Id, OpportunityId From OpportunityLineItem WHERE OpportunityId IN :oppIds]);
//		List<Contract> updatedContracts = new List<Contract>();
//		Set<Id> updatedContractIds = new Set<Id>();
//		for(OpportunityLineItem oli : Trigger.new){
//
//			OpportunityLineItem queryOLI = oppOLIsMap.get(oli.id);
//
//			if (queryOLI.Opportunity.Contract_Required__c == 'Yes'){
//				integer counter = 0;
//				string buildprods = '';
//				for (OpportunityLineItem opplines : oppProducts){
//					if (opplines.OpportunityId == oli.OpportunityId){
//						if (counter == 0){
//							buildprods = opplines.Product2.Name;
//							counter++;
//						} else {
//							buildprods = buildprods+','+opplines.Product2.Name;
//						}
//					}
//				}
//
//				for (Contract contract : oppContracts){
//					if (contract.Related_Opportunity__c == oli.OpportunityId){
//						contract.Products__c = 	buildprods;
//						if (!updatedContractIds.contains(contract.Id)){
//							updatedContractIds.add(contract.Id);
//							updatedContracts.add(contract);
//						}
//						break;
//					}
//				}
//			}
//		}
//		if (updatedContracts.size() > 0){
//			update updatedContracts;
//		}
//	}
//
//	if (trigger.isDelete){
//		Map<Id, OpportunityLineItem> oppOLIsMap
//                    = new Map<Id, OpportunityLineItem>([SELECT Id, Opportunity.Contract_Required__c, Opportunity.Amount
//                                                    FROM OpportunityLineItem
//                                                    WHERE Id IN :Trigger.old]);
//
//		for(OpportunityLineItem oli : Trigger.old){
//
//			OpportunityLineItem queryOLI = oppOLIsMap.get(oli.id);
//
//			if (queryOLI.Opportunity.Contract_Required__c == 'Yes'){
//				integer counter = 0;
//				List <OpportunityLineItem> OpProds = [Select Product2.Name, Product2Id, OpportunityId From OpportunityLineItem WHERE OpportunityId=:oli.OpportunityId AND Product2Id != :oli.Product2Id];
//							string buildprods = '';
//
//				for (OpportunityLineItem opplines : OpProds){
//					if (counter == 0){
//						buildprods = opplines.Product2.Name;
//						counter++;
//					} else {
//						buildprods = buildprods+','+opplines.Product2.Name;
//					}
//				}
//
//				Contract contract = [Select Id, Products__c, Contract_Renewal_Amount__c From Contract WHERE Related_Opportunity__c = :oli.OpportunityId Limit 1];
//				contract.Products__c = 	buildprods;
//				contract.Contract_Renewal_Amount__c = 	queryOLI.Opportunity.Amount-oli.TotalPrice;
//				update contract;
//			}
//		}
//	}

}