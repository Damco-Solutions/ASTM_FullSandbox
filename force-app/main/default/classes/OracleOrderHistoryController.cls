/**
 * Created by johnpernock from OpenGate Consulting on 2019-08-26.
 */

public without sharing class OracleOrderHistoryController {
    @AuraEnabled
    public static String getOrderHistory(Id accountId) {
        List<Account> acctInfo = [SELECT Id, Oracle_Account_Number__c FROM Account WHERE Id = :accountId LIMIT 1];
        if (acctInfo.size() > 0) {
            if (acctInfo[0].Oracle_Account_Number__c != null && acctInfo[0].Oracle_Account_Number__c != '') {
                String returnStr = OrderHistoryService.getOrderHistoryData(acctInfo[0].Oracle_Account_Number__c, '', '');
                return returnStr;
            } else {
                return '';
            }
        } else {
            return '';
        }
    }
}