/**
 * Created by Vladyslav Kravchuk on 7/25/2021.
 */

@IsTest
private class CalloutClientTest {
    private static final String endpoint = 'my/test/endpoint';
    private static final Integer responseSuccessStatusCode = 200;
    private static final Integer responseFailureStatusCode = 400;

    @isTest
    static void setRequestHeaderAsStringTest() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        String headerKey = 'headerKey';
        String headerValue = 'headerValue';

        CalloutClient callout = new CalloutClient(endpoint).setHeader(headerKey, headerValue);
        callout.get();

        Test.stopTest();

        System.assertEquals(headerValue, callout.request.getHeader(headerKey));
    }

    @isTest
    static void postTest() {
        callRestMethodAndAssertResult('POST', 'POST payload');
    }

//    @isTest
//    static void postTestFailure() {
//        Boolean error = false;
//
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, new FailureCalloutMock());
//
//        try {
//            new CalloutClient(endpoint).post('POST payload');
//        } catch (Exception e) {
//            error = true;
//        }
//
//        Test.stopTest();
//        System.assert(error,'The error should be thrown');
//    }

    @isTest
    static void putTest() {
        callRestMethodAndAssertResult('PUT', 'PUT payload');
    }

    @isTest
    static void patchTest() {
        callRestMethodAndAssertResult('PATCH', 'PATCH payload');
    }

    @isTest
    static void deleteTest() {
        callRestMethodAndAssertResult('DELETE', null);
    }

    private static void callRestMethodAndAssertResult(String methodName, String requestBody) {
        HttpResponse response = new HttpResponse();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        switch on methodName {
            when 'POST' {
                response = new CalloutClient(endpoint).post(requestBody);
            }
            when 'PUT' {
                response = new CalloutClient(endpoint).put(requestBody);
            }
            when 'PATCH' {
                response = new CalloutClient(endpoint).patch(requestBody);
            }
            when 'DELETE' {
                response = new CalloutClient(endpoint).del();
            }
        }

        Test.stopTest();

        System.assert(response.getStatusCode() == responseSuccessStatusCode);
        if (methodName != 'DELETE') System.assertEquals(requestBody, response.getBody());

    }

    public class SuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(request.getBody());
            response.setStatusCode(responseSuccessStatusCode);
            return response;
        }
    }

    public class FailureCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(request.getBody());
            response.setStatusCode(responseFailureStatusCode);
            return response;
        }
    }
}