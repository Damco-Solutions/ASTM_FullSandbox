/**
 * Created by William McCullough from OpenGate Consulting on 1/31/2019.
 */

global with sharing class OrderHistoryService {

    webService static String getOrderHistoryData(String accountNumber, String dateFrom, String dateTo) {

        String method = 'POST';
        String resourceName = 'orderhistory';
        /* Example requests
        String requestBody = '{"Filter":{"AccountNumber":"148689"},"Paging":{"PageSize":100,"PageIndex":1}';
        String requestBody = '{"Filter":{"DateFrom":"\\/Date(1505241000000+0530)\\/","DateTo":"\\/Date(1505500200000+0530)\\/","AccountNumber":"148689"},"Paging":{"PageSize":100,"PageIndex":1}';
         */
        String requestBody =  '{"Filter":{"AccountNumber":' + accountNumber + '},"Paging":{"PageSize":100,"PageIndex":1}';

        //send request to order history server
        HttpResponse res = OrderHistoryCallout.getOrderHistoryHttpResponse(method, resourceName, requestBody);
        return res.getBody();
    }
}