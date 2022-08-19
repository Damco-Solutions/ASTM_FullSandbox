/**
 * Created by johnpernock from OpenGate Consulting on 8/29/19.
 */
@IsTest(SeeAllData = true)
public with sharing class OracleOrderHistoryControllerTest {
    @IsTest
    static void testOracleAccountWithNumber() {
        Account ca = new Account(Name='testaccount',Oracle_Account_Number__c='111222333',BillingCountryCode='US');
        insert ca;

        Test.startTest();
        OracleOrderHistoryController.getOrderHistory(ca.Id);
        Test.stopTest();
    }
    @IsTest
    static void testOracleAccountWithout() {
        Account ca = new Account(Name='testaccount',Oracle_Account_Number__c='',BillingCountryCode='US');
        insert ca;

        Test.startTest();
        OracleOrderHistoryController.getOrderHistory(ca.Id);
        Test.stopTest();
    }
    @IsTest
    static void testOracleNoAccount() {
        Test.startTest();
        OracleOrderHistoryController.getOrderHistory('001000000ddaoat');
        Test.stopTest();
    }
}