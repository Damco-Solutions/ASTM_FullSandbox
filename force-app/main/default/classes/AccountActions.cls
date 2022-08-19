public with sharing class AccountActions {

    public static void SetCountryLookup(List<Account> accounts) {
        //assumes Before context in trigger

        //get a list of 2 letter codes for our query on Country__c
        List<String> country2Letter = new List<String>();
        for(Account acc: accounts) {
            if(!country2Letter.contains(acc.BillingCountryCode)) {
                if(acc.BillingCountryCode!= null) {
                    country2Letter.add(acc.BillingCountryCode);
                }
            }               
        }
        System.debug(country2Letter);
    
        //Get a map of 2 letter codes to Country__c to set fields on Account
        Map<String, Country__c> mapCountries = new Map<String, Country__c>();
        List<Country__c> countries = [SELECT Id, Name, country2Letter__c, Region__c  FROM Country__c WHERE country2Letter__c IN: country2Letter];
        for (Country__c country: countries) {
            mapCountries.put(country.country2Letter__c, country);
        }
        //loop through our Accounts and update the fields
        for (Account a: accounts) {
            if(a.BillingCountryCode != null) {
                Country__c cntry = mapCountries.get(a.BillingCountryCode);
                if(cntry != null) {
                    a.Country__c = cntry.Id;
                }
            }
        }
    }
}