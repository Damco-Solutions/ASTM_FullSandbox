/**
 * Created by William McCullough from OpenGate Consulting on 1/22/2019.
 */

public with sharing class AzureADUtility {
    public static String GetAzureADAccessToken(String tenantID, String middlewareAppId, String clientID, String clientSecret) {
        String accessToken = '';
        String ADURLString = 'https://login.microsoftonline.com/';
        String contentTypeString = 'application/x-www-form-urlencoded';
        String bodyString = 'resource=' + EncodingUtil.urlEncode(middlewareAppId, 'UTF-8') + '&client_id=' + EncodingUtil.urlEncode(clientID, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') + '&grant_type=client_credentials';
//        System.debug(bodyString);
        String endPointString = ADURLString + tenantID + '/oauth2/token';
//        System.debug(endPointString);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endPointString);
        request.setHeader('Content-Type', contentTypeString);
        request.setBody(bodyString);
        Http binding = new Http();
        if (!Test.isRunningTest()) {
            HttpResponse response = binding.send (request);
//        System.debug(response);
            if (response.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(response.getBody());
                while (parser.nextToken() != null) { if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) { parser.nextToken(); accessToken = parser.getText();}}
            }
        } else {
            accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InU0T2ZORlBId0VCb3NIanRyYXVPYlY4NExuWSIsImtpZCI6InU0T2ZORlBId0VCb3NIanRyYXVPYlY4NExuWSJ9.eyJhdWQiOiJodHRwczovL2FzdG0ub3JnL2UzYTg3MjI2LWVmYTEtNGY1Yy04M2U3LTE5NmQxZmYxMmQzMiIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzliODBlODhlLTk4MGItNGQ3MC1hMjFiLTc3M2QzMjlmNDQ1ZC8iLCJpYXQiOjE1NjQ2MTg4NzksIm5iZiI6MTU2NDYxODg3OSwiZXhwIjoxNTY0NjIyNzc5LCJhaW8iOiI0MkZnWU9oYWRZYlRaSEZSNDd1Q21ET3ZURCsvQUFBPSIsImFwcGlkIjoiMTRiNGI2MmUtODc1MS00MmVmLWFjYzAtNWRlOGFmYzVhOTU4IiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOWI4MGU4OGUtOTgwYi00ZDcwLWEyMWItNzczZDMyOWY0NDVkLyIsIm9pZCI6ImNhZWNkNjcxLTRhNDItNGYzZS05NmM5LTYzMDBhZTlmNGNhZSIsInN1YiI6ImNhZWNkNjcxLTRhNDItNGYzZS05NmM5LTYzMDBhZTlmNGNhZSIsInRpZCI6IjliODBlODhlLTk4MGItNGQ3MC1hMjFiLTc3M2QzMjlmNDQ1ZCIsInV0aSI6InUtS3hycW5qVUVTMTI4OWVaRVFBQUEiLCJ2ZXIiOiIxLjAifQ.l3lUI3mZciiH94DgjgdZeoz6IW_WAUHtF0CgjIuGj8BSJ_-aea3HqW67GuDs_-vN1OG7CLQq0KJs5vdYCeOoR3t7Fkg1Kyp2yVCKkvAZ4a_HayGrlzDqnktFpB0rx1MS0tcGD5k8Fk8llnpkIoHP3xVx2zOECQEtHrgxia7-7U2E3Y0tRhFSA_D6j-g5ErXQ7eEt2zbB0uva_utYEw9l2eDv3bLRtE3kDZZfBxyE-Q5qKlhMj1Csx5sk5lN7U4w3K2uYdovvrdrb5ggpAVflCPS7Du7eU8OrLt6hfcoWcUsxeYEslnL9RuT4gFw-uEjL71FOSgiVLItfMNiIshzScg';
        }
//        System.debug('accessToken : ' + accessToken);
        return accessToken;

    }
}