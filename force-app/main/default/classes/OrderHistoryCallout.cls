/**
 * @author William McCullough from OpenGate Consulting on 1/22/2019.
 * @description Handles the callouts to Azure and Order History API
 **/

public with sharing class OrderHistoryCallout {
    /**
    *	@description Query the custom object for the Order History API settings
    * 	@return Returns a single Order History API setting
    **/
    public static Order_History_API__c orderHistoryAPIsettings {

        get {

            if (orderHistoryAPIsettings == null) {

                orderHistoryAPIsettings = Order_History_API__c.getInstance();
            }
            return orderHistoryAPIsettings;
        }
        set;
    }
    /**
    *	@description Makes a call to get the Azure AD Token then formats and sends an HTTP request to the Order History API
    *   @param String method
    *   @param String resourceName
    *   @param String requestBody
    * 	@return Returns a response object from an HTTP request
    **/
    public static HttpResponse getOrderHistoryHttpResponse(String method, String resourceName, String requestBody) {
        // get Azure AD authentication token
        String accessTokenString = AzureADUtility.GetAzureADAccessToken(orderHistoryAPIsettings.Azure_AD_Tenant_Id__c, orderHistoryAPIsettings.Middleware_App_ID__c, orderHistoryAPIsettings.Azure_Client_ID__c, orderHistoryAPIsettings.Azure_Client_Secret__c);
        System.debug('accessTokenString from Azure AD');
        System.debug(accessTokenString);
        System.debug('-----------------');

        String APIKey = orderHistoryAPIsettings.Middleware_Client_Key__c;
        System.debug('APIKey (Middleware_Client_Key__c)');
        System.debug(APIKey);
        System.debug('-----------------');

        String APPId = orderHistoryAPIsettings.Middleware_Client_ID__c;
        System.debug('APPId (Middleware_Client_ID__c)');
        System.debug(APPId);
        System.debug('-----------------');

        String requestHttpMethod = method;
        System.debug('requestHttpMethod');
        System.debug(requestHttpMethod);
        System.debug('-----------------');

        //combine the URL from our custom setting with the resource we want to access
        String requestUri = orderHistoryAPIsettings.Middleware_Request_URL__c + resourceName;
        requestUri = EncodingUtil.urlEncode(requestUri.toLowerCase(), 'UTF-8').toLowerCase();
        System.debug('requestUri');
        System.debug(requestUri);
        System.debug('-----------------');

        //get Unix Time Stamp
        String requestTimeStamp = getUnixTimeStamp();
        System.debug('timestamp');
        System.debug(requestTimeStamp);
        System.debug('-----------------');

        //get nonce
        String nonce = getNonce();
        System.debug('nonce');
        System.debug(nonce);
        System.debug('-----------------');

        //generate MD5 hash of request return as Base 64 string        
        String requestContentBase64String = getMD5StringAsBase64(requestBody);
        System.debug('requestBody as MD5 hash/base 64 string');
        System.debug(requestContentBase64String);
        System.debug('-----------------');

        //concatenate values to build raw request string
        String signatureRawData = APPId + requestHttpMethod + requestUri + requestTimeStamp + nonce + requestContentBase64String;
        System.debug('signatureRawData - the concatenated value to encode with SHA256');
        System.debug(signatureRawData);
        System.debug('-----------------');

        //get SHA256 hash for API string
        String requestSignatureBase64String = getSHA256StringAsBase64(signatureRawData, APIKey);
        System.debug('requestSignatureBase64String');
        System.debug(requestSignatureBase64String);
        System.debug('-----------------');

        //build string for API request - colon between each element
        String APIString = APPId + ':' + requestSignatureBase64String + ':' + nonce + ':' + requestTimeStamp;
        System.debug('APIString');
        System.debug(APIString);
        System.debug('-----------------');

        //build request
        HttpRequest request = new HttpRequest();

        String endPoint = orderHistoryAPIsettings.Middleware_Request_URL__c + resourceName;
        request.setEndpoint(endPoint);
        System.debug('endPoint');
        System.debug(endPoint);
        System.debug('-----------------');

        request.setMethod(method);

        //Example body-> request.setBody('{"Filter":{"AccountNumber":000360914},"Paging":{"PageSize":100,"PageIndex":1}');
        request.setBody(requestBody);
        System.debug('requestBody');
        System.debug(requestBody);
        System.debug('-----------------');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('ApiKey', APIString);
        request.setHeader('Authorization', 'Bearer ' + accessTokenString);
        System.debug('request');
        System.debug(request);
        System.debug('-----------------');

        //send request and return response
        Http http = new Http();
        if (!Test.isRunningTest()) {
            HttpResponse response = http.send(request);
            System.debug(response);
            System.debug(response.getBody());
            return response;
        } else {
            HttpResponse response = new HttpResponse();
            response.setStatus('Completed');
            response.setStatusCode(200);
            response.setBody('[{"Errors": null, "Success": true, "UserMessage": null,"OrderDetail": [{"BillToAddress": "Accounts Payable\n199 Benson Road\nMIDDLEBURY, CT06749", "BillToCustomer": " Chemtura Corp.", "BillToCustomer": " Chemtura Corp.", "BillToLocation": "1675197", "GrandTotal": 505,"OrderCategoryCode": "ORDER","OrderNo": "6558697","PrepayInformation":"PTP0027562,, visa: 8659 - EXP: 01-MAY-18 Verisign #: 2rvr9c2 || Grand Total: 540.35 ||Tax: 35.35 || CC DATE: 23-OCT-15","ShipMethod": "Standard Service","ShipToAddress": "1020 King George Post Rd\nFORDS, NJ08863","ShipToCustomer": " Chemtura Corp.","ShipToLocation": "1339976","Shipper": null,"TimeStamp": "23-OCT-15 05.53.04.000000 PM","Tracking": null}],"Paging": {"PageIndex": 1,"PageSize": 1,"TotalPages": 6}}]');
            return response;
        }
    }

    public static String getUnixTimeStamp() {
        //generate timestamp as number of seconds between Now() and Unix epoch (Jan. 1, 1970)
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_datetime.htm -> getTime() returns the number of milliseconds since January 1, 1970, 00:00:00 GMT
        //check using this site-> https://www.unixtimestamp.com/
        Long timeDifferenceSeconds = Datetime.now().getTime() / 1000;
        return String.valueOf(timeDifferenceSeconds);
    }

    public static String getNonce() {
        Long randomLong = Crypto.getRandomLong();
        //ensure that we have a positive integer (i.e. unsigned)
        if (randomLong < 0) {
            randomLong = randomLong * -1;
        }
        return String.valueOf(randomLong);
    }

    public static String getMD5StringAsBase64(String contentToHash) {
        //verify using -> https://passwordsgenerator.net/md5-hash-generator/
        /*
        data to verify with:
        contentToHash = 'Test webapi content!'

        computed MD5 hash:
        888953085D12133C2889827A04610EF0
        */
//        Blob requestBlob = Blob.valueOf(contentToHash);
        //encode to UTF-16 Unicode characters before hash
        //https://8gwifi.org/HexToStringFunctions.jsp
        Blob requestBlob = Charset.encode(contentToHash, 'UTF-16LE');
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        return EncodingUtil.base64Encode(hash);
    }

    public static String getSHA256StringAsBase64(String contentString, String keyString) {
        //verify using -> https://www.freeformatter.com/hmac-generator.html#ad-output
        /*
        data to verify with:
        contentString = 'Test webapi content!'
        keyString = '123456789'

        computed HMAC:
        33a67b584fbcce489f3ef8048168dbc3e610d495b612a32fdfeb0d8b0aa48342
        */
        Blob blobData = Blob.valueOf(contentString);
        Blob privateKey = EncodingUtil.base64Decode(keyString);
        Blob hmac = Crypto.generateMac('HmacSHA256', blobData, privateKey);

        return EncodingUtil.base64Encode(hmac);
    }
}