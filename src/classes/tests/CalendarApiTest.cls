/**
 * Created by Vladyslav Kravchuk on 7/26/2021.
 */

@IsTest
private class CalendarApiTest {
    private static final String calendarId = 'test@gmail.com';


    @IsTest
    static void getOwnerCalendarIdTest() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(200, mockCalendarId()));
        String cId = new CalendarApi().getOwnerCalendarId();
        Test.stopTest();

        System.assertEquals(calendarId, cId, 'Calendar Ids should be equal');
    }

    @IsTest
    static void insertEventTest() {
        assertRestMethodResponse('POST', 200, mockPOSTResponse());
    }

    @IsTest
    static void updateEventPUTTest() {
        assertRestMethodResponse('PUT', 200, mockPOSTResponse());
    }

    @IsTest
    static void updateEventPATCHTest() {
        assertRestMethodResponse('PATCH', 200, mockPOSTResponse());
    }

    @IsTest
    static void deleteEventTest() {
        assertRestMethodResponse('DELETE', 204, null);
    }

    private static void assertRestMethodResponse(String methodName, Integer statusCode, String requestBody) {
        HttpResponse response = new HttpResponse();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(statusCode, requestBody));

        switch on methodName {
            when 'POST' {
                response = new CalendarApi(calendarId).insertEvent(requestBody);
            }
            when 'PUT' {
                response = new CalendarApi(calendarId).updateEventPUT('someTestEvenId', requestBody);
            }
            when 'PATCH' {
                response = response = new CalendarApi(calendarId).updateEventPATCH('someTestEvenId', requestBody);
            }
            when 'DELETE' {
             response = new CalendarApi(calendarId).deleteEvent('someTestEvenId');
            }
        }
        Test.stopTest();

        if (methodName != 'DELETE') System.assertEquals(requestBody, response.getBody(), 'Responses should be equal');
        System.assertEquals(statusCode, response.getStatusCode());
    }

    private static String mockCalendarId() {
        return '{"items": [\n' +
                '  {\n' +
                '   "id": "' + calendarId + '",' +
                '   "accessRole": "owner"' +
                '}]' +
                '}';
    }

    private static String mockPOSTResponse() {
        return '{' +
                ' "summary": "TEST",' +
                ' "start": {' +
                '  "dateTime": "2021-06-24T13:00:00+03:00"' +
                ' },' +
                ' "end": {' +
                '  "dateTime": "2021-06-24T13:40:00+03:00"' +
                ' }' +
                '}';
    }

    public class CalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        private String requestBody;

        public CalloutMock(Integer statusCode, String requestBody) {
            this.statusCode = statusCode;
            this.requestBody = requestBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);

            if (requestBody != null) response.setBody(requestBody);
            return response;
        }
    }
}