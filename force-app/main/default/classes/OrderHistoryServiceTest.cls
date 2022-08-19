/**
 * Created by William McCullough from OpenGate Consulting on 7/31/2019.
 */

@IsTest
private class OrderHistoryServiceTest {
    @TestSetup
    static void setupOrderHistoryServiceTestData() {
        Order_History_API__c newOrderHistoryAPI = new Order_History_API__c(
                Middleware_App_ID__c = 'https://astm.org/e3a87226-efa1-4f5c-83e7-196d1ff12d32',
                Middleware_Client_ID__c = '4d53bce03ec34c0a911182d4c228ee6c',
                Middleware_Client_Key__c = 'A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=',
                Middleware_Request_URL__c = 'https://rtdb-astm-prod.azurewebsites.net/apiconnector/',
                Azure_AD_Tenant_Id__c = '9b80e88e-980b-4d70-a21b-773d329f445d',
                Azure_Client_ID__c = '14b4b62e-8751-42ef-acc0-5de8afc5a958',
                Azure_Client_Secret__c = 'M5phgiuJbdvzXyuqgKWEzo3Kp7N7R7lexg8c5GPNx5Q='
        );
        insert newOrderHistoryAPI;

    }
    @IsTest
    static void testOrderHistoryServiceCallout() {
        //get URL's for calls
        Order_History_API__c orderHistoryAPI = Order_History_API__c.getOrgDefaults();
        String ADURLString = 'https://login.microsoftonline.com/';
        ADURLString = ADURLString + orderHistoryAPI.Azure_AD_Tenant_Id__c + '/oauth2/token';
        Test.startTest();
        OrderHistoryService.getOrderHistoryData('148689', '\\/Date(1505241000000+0530)\\/', '\\/Date(1505500200000+0530)\\/');
        Test.stopTest();
    }
    @IsTest
    static void testGetADToken() {
        Order_History_API__c orderHistoryAPI = Order_History_API__c.getOrgDefaults();

        Test.startTest();
        String accessTokenString = AzureADUtility.GetAzureADAccessToken(orderHistoryAPI.Azure_AD_Tenant_Id__c, orderHistoryAPI.Middleware_App_ID__c, orderHistoryAPI.Middleware_Client_ID__c, orderHistoryAPI.Middleware_Client_Key__c);
        Test.stopTest();
        System.assert(String.isNotBlank(accessTokenString), 'Access Token should be returned');
    }
}