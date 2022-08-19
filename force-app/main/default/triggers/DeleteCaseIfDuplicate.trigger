trigger DeleteCaseIfDuplicate on Case (after insert) {
    
    Set<Id> NewCaseId = new Set<Id>();
    If(Trigger.isInsert && Trigger.isAfter){
        for(Case cs:Trigger.new){
            NewCaseId.add(cs.Id);
        }
        
        DeleteCaseIfduplicateHelper.methodtodelete(NewCaseId);
        
    }
}