/**
 * Created by wmccu on 9/24/2020.
 */

trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    new OpportunityTriggerHandler().run();
    
     if(Trigger.isBefore) {
    if(Trigger.isUpdate || Trigger.isInsert) {
      //Handle setting country lookup
      List<Opportunity> countryInserted = new List<Opportunity>();
      for (Opportunity acct: Trigger.new) {
        System.debug(acct);
          if(Trigger.isInsert ){
             if( acct.Account_Country__c !=null) {
                 system.debug('acct.Account_Country__c' +acct.Account_Country__c);
                 countryInserted.add(acct);
           } 
          }
            if(Trigger.isUpdate )
           if( Trigger.oldMap.get(acct.Id).Account_Country__c != Trigger.newMap.get(acct.Id).Account_Country__c ){
              countryInserted.add(acct);

       }

      }
      if (countryInserted.size()>0) {
          OpportunityTriggerHandler.SetCountryLookup(countryInserted);
      }
    }
  }
}