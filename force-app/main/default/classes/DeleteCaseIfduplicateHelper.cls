/**
Created By Damco on 06.13.2022
This Helper class is in use for DeleteCaseIfduplicate Trigger.
In order to restrict case duplication when customer sends email to multiple Email Services.
*/
public class DeleteCaseIfduplicateHelper {
    @future
    public static void methodtodelete(Set<Id> CaseId){
        
        List<Case> OldCase = new List<Case>();
        String CaseSubject;
        DateTime CaseCreatedDate;
        DateTime EMCreatedDate;
        String WebEmail;
        
        
        List<Case> NewCases = [Select Id,Subject,Origin,CreatedDate,CaseNumber,OwnerId,SuppliedEmail FROM Case WHERE Id IN: CaseId ]; 
        OldCase = [SELECT Id, Subject,CreatedDate,SuppliedEmail,CaseNumber,OwnerId,Origin FROM Case WHERE CreatedDate =TODAY AND Id NOT IN: CaseId];
        List<Case> TobeDeleted = new List<Case>();
        //Set<Id> NewCaseId = new Set<Id>();
        
        
        
        for (Case c : NewCases) {
            system.debug('c.Id' +c.Id + '**' +c.CaseNumber +'&&' +c.OwnerId);
            if (c.Origin <> null && c.Origin == 'Email') {
                
                CaseSubject=c.Subject;
                CaseCreatedDate = c.CreatedDate;
                WebEmail = c.SuppliedEmail;
                //NewCaseId.add(c.Id);
            }
        }
        
        if (OldCase.size() > 0 ) {
            
            for(Case em:OldCase){
                system.debug('em.Id' +em.Id);
                if(em.Subject==CaseSubject && em.SuppliedEmail == WebEmail){
                    EMCreatedDate= em.CreatedDate;
                }
                
            }
            
            if(EMCreatedDate !=null && CaseCreatedDate !=null){
                
                decimal millisecs = decimal.valueOf(CaseCreatedDate.getTime() - EMCreatedDate.getTime());
                decimal seconds = millisecs/1000;
                
                for(Case cs:NewCases){
                    system.debug('seconds' +seconds);
                    if(cs.Subject == CaseSubject && seconds < 10){
                        system.debug('Insidelastfor' +cs.Subject +seconds);
                        TobeDeleted.add(cs);
                    }
                }
                
                if(TobeDeleted.size()>0){
                    Delete TobeDeleted;
                    system.debug('TobeDeleted');
                }
            } 
        }
    }
    
}