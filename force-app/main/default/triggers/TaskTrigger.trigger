trigger TaskTrigger on Task (before insert){
	if (Trigger.isInsert && Trigger.isBefore) {
		Set<Id> contactIds = new Set<Id>();
	    for (Task tsk : Trigger.new){
			if (String.isEmpty(tsk.WhatId) && !String.isEmpty(tsk.WhoId)){
				if (tsk.WhoId.getsobjecttype() == Contact.sObjectType && !contactIds.contains(tsk.WhoId)){
					contactIds.add(tsk.WhoId);
				}
			}
		}
		if (contactIds.size() > 0){
			List<Contact> contactAccounts = [SELECT Id, AccountId FROM Contact WHERE Id =: contactIds];
			for (Task tsk : Trigger.new){
				for (Contact tskContact : contactAccounts){
					if (tsk.WhoId == tskContact.Id && String.isEmpty(tsk.WhatId)){
						if (!String.isEmpty(tskContact.AccountId)){
							tsk.WhatId = tskContact.AccountId;
						}
					}
				}
			}
		}
	}		
}