@IsTest
private class AccountActionsTest {
    static testMethod void testAccounts() {
        //Country for the test
        Country__c testcountry = new Country__c(Name = 'US', country2Letter__c = 'US', Region__c = 'North America');
        insert testcountry;
        

        //account with zip code that matches one in table (CFDT)
        Account testAccount = new Account(
                Name = 'TestAccountCountry',
				BillingCountryCode = 'US'

        );


        Test.startTest();
        Insert testAccount ;


        Test.stopTest();

    }

}