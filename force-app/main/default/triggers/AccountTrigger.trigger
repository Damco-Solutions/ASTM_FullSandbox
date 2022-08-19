trigger AccountTrigger on Account (before delete, before update, before insert, after delete, after update, after insert) {
 if(Trigger.isBefore) {
    if(Trigger.isUpdate || Trigger.isInsert) {
      //Handle setting country lookup
      List<Account> countryInserted = new List<Account>();
      for (Account acct: Trigger.new) {
        System.debug(acct);
          if(Trigger.isInsert ){
             if( acct.BillingCountryCode !=null) {
                 system.debug('BillingCountryCode' +acct.BillingCountryCode);//add
                 countryInserted.add(acct);
           } 
          }
            if(Trigger.isUpdate )
           if( Trigger.oldMap.get(acct.Id).BillingCountryCode != Trigger.newMap.get(acct.Id).BillingCountryCode ){
              countryInserted.add(acct);

       }

      }
      if (countryInserted.size()>0) {
          AccountActions.SetCountryLookup(countryInserted);
      }
    }
  }
}