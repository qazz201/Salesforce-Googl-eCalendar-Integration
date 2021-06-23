public class GoogleAuthController {
    @AuraEnabled
    public static Map<String, Object> setAccessToken(String authorizationCode) {
        System.debug(authorizationCode);
        Map<String, Object> respBody;

        Google_Credential__mdt googleCredentials = getGoogleCredentials();
        Google_Auth_Token__c calendarToken = getGoogleToken();

        String requestBody = 'code=' + authorizationCode + '&'
                + 'client_id=' + googleCredentials.Client_Id__c + '&'
                + 'client_secret=' + googleCredentials.Client_Secret__c + '&'
                + 'redirect_uri=' + googleCredentials.Redirect_Uri__c + '&'
                + 'grant_type=authorization_code';

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();

        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(googleCredentials.Token_Uri__c);
        httpRequest.setHeader('Host', 'oauth2.googleapis.com');
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpRequest.setBody(requestBody);
        httpRequest.setTimeout(12000);

        httpResponse = http.send(httpRequest);

        try {
            Integer requestStatus = httpResponse.getStatusCode();
            respBody = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());

            if (requestStatus == 200) {
                String accessToken = (String) respBody.get('access_token');

                System.debug(accessToken);

                if (calendarToken == null) {
                    insert new Google_Auth_Token__c(
                            Access_Token__c = accessToken,
                            Authorization_Code__c = authorizationCode);
                } else {
                    calendarToken.Access_Token__c = accessToken;
                    calendarToken.Authorization_Code__c = authorizationCode;
                    upsert calendarToken;
                }

            } else {
                System.debug(respBody);
            }
        } catch (Exception e) {
            System.debug(e);
        }

        return respBody;
    }

    private static Integer getAccessToken() {
        return 1;
//        Integer requestStatus = 0;
//
//        String requestBody = 'code=' + authCode + '&'
//                + 'client_id=' + clientId + '&'
//                + 'client_secret=' + clientSecret + '&'
//                + 'redirect_uri=https://wise-moose-kvvood-dev-ed.lightning.force.com/c/gCalendarStartPage.app&'
//                + 'grant_type=authorization_code';
//
//        Http http = new Http();
//        HttpRequest httpRequest = new HttpRequest();
//        HttpResponse httpResponse = new HttpResponse();
//
//        httpRequest.setMethod('POST');
//        httpRequest.setEndpoint(tokenEndpoint);
//        httpRequest.setHeader('Host', 'oauth2.googleapis.com');
//        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
//        httpRequest.setBody(requestBody);
//        httpRequest.setTimeout(12000);
//
//        httpResponse = http.send(httpRequest);
//
//        try {
//            requestStatus = httpResponse.getStatusCode();
//
//            if (requestStatus == 200) {
//                Map<String, Object> respBody = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
//                accessToken = (String) respBody.get('access_token');
//
//
//            } else {
//
//                System.debug(requestStatus + '_STATUSs');
//                System.debug(httpRequest);
//            }
//        } catch (Exception e) {
//            System.debug(e);
//        }
//        return requestStatus;
    }


    private static Google_Credential__mdt getGoogleCredentials() {
        return [
                SELECT Client_Id__c,
                        Client_Secret__c,
                        Auth_Uri__c,
                        Token_Uri__c,
                        Redirect_Uri__c,
                        Access_Type__c,
                        Include_Granted_Scopes__c
                FROM Google_Credential__mdt
                LIMIT 1
        ];
    }

    private static Google_Auth_Token__c getGoogleToken() {
        return [
                SELECT Id,
                        Authorization_Code__c,
                        Access_Token__c,
                        CreatedDate
                FROM Google_Auth_Token__c
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
    }

    @AuraEnabled
    public static String getCalendarList() {
        return '';
//        String calendarEndpoint = 'https://www.googleapis.com/calendar/v3/users/me/calendarList/';
//
//        Http http = new Http();
//        HttpRequest httpReq = new HttpRequest();
//        HttpResponse HttpRes = new HttpResponse();
//
//        httpReq.setEndpoint(calendarEndpoint);
//        httpReq.setMethod('GET');
//        httpReq.setHeader('Content-Type', 'application/json');
//        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
//
//        try {
//            HttpRes = http.send(httpReq);
//            System.debug(httpRes.getStatusCode() + accessToken + 'AUTh' + authCode);
//            if (httpRes.getStatusCode() == 200) {
//
//                System.debug('#### CALENDARSSSSSSSSSSS ' + HttpRes.getBody());
//
//            } else {
//                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
//                        + 'Status ' + HttpRes.getStatus() + ' and Status Code ' + HttpRes.getStatuscode();
//            }
//        } catch (System.Exception e) {
//            System.debug('#### Exception Executed ' + e.getStackTraceString() + '  ' + e.getMessage());
//        }
//        return HttpRes.getBody();
    }


}


//    {
//        "web": {
//    "client_id": "959875857857-d42ta4q3iuosq018rcsgiqs160qsnqm2.apps.googleusercontent.com",
//        "project_id": "salesforce-integration-317114",
//    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//    "token_uri": "https://oauth2.googleapis.com/token",
//    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//    "client_secret": "kmSdw67KqwjX7KeR2Mj79Wnb",
//    "redirect_uris": [
//    "https://wise-moose-kvvood-dev-ed--c.visualforce.com/apex/googleCalendarIntegration"
//    ]
//    }
//}
////
//
//https://accounts.google.com/o/oauth2/v2/auth?
//client_id=959875857857-d42ta4q3iuosq018rcsgiqs160qsnqm2.apps.googleusercontent.com&
//response_type=code&
//scope=https%3A//www.googleapis.com/auth/calendar%20https%3A//www.googleapis.com/auth/calendar.events&
//access_type=offline&
//include_granted_scopes=true&
//state=state_parameter_passthrough_value&
//redirect_uri=https%3A//wise-moose-kvvood-dev-ed.lightning.force.com/c/gCalendarStartPage.app

