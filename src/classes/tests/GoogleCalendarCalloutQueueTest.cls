/**
 * Created by Vladyslav Kravchuk on 7/22/2021.
 */

@IsTest
private class GoogleCalendarCalloutQueueTest {
    private static final Integer eventCount = 90;

    @TestSetup
    static void setup() {
        List<Event> events = TestDataFactory.createEvents(eventCount);
        insert events;
    }

    @IsTest
    static void insertTest() {
        assertQueueResult(EventOperationType.INSERT_TYPE);
    }

    @IsTest
    static void updateTest() {
        assertQueueResult(EventOperationType.UPDATE_TYPE);
    }

    private static void assertQueueResult(String operationType) {
        List<Event> events = getEventList();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, setRequestMocks());
        System.enqueueJob(new GoogleCalendarCalloutQueue(getQuePayload(operationType, events)));
        Test.stopTest();

        List<Event> eventsUpdated = getEventList();

        System.assertEquals(false, areAllEventsHaveGoogleId(events), 'Events should not have Google event Id');
        System.assertEquals(true, areAllEventsHaveGoogleId(eventsUpdated), 'Events should have Google event Id');
    }

    private static List<Event> getEventList() {
        Set<String> evFieldList = Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap().keySet();
        List<String> strList = new List<String>(evFieldList);
        String fields = string.join(strList, ',');

        return Database.query('SELECT ' + fields + ' FROM Event Limit ' + eventCount);
    }

    private static MultiRequestMock setRequestMocks() {
        RequestMock mimicGETResp = new RequestMock(200, mockGETResponse());
        RequestMock mimicPOSTResp = new RequestMock(200, mockPOSTResponse());

        MultiRequestMock multiRequestMock = new MultiRequestMock();
        multiRequestMock.addMock('GET', mimicGETResp);
        multiRequestMock.addMock('POST', mimicPOSTResp);
        multiRequestMock.addMock('PUT', mimicPOSTResp);

        return multiRequestMock;
    }

    private static Boolean areAllEventsHaveGoogleId(List<Event> events) {
        for (Event event : events) {
            if (event.Google_Event_Id__c == null) return false;
        }
        return true;
    }

    private static String mockGETResponse() {
        return '{"items": [\n' +
                '  {\n' +
                '   "id": "test@gmail.com",\n' +
                '   "accessRole": "owner"' +
                '}]' +
                '}';
    }

    private static String mockPOSTResponse() {
        return '{"id": "gk0m0ch0kmf86hbevj3plv00kg"}';
    }

    private static List<GoogleCalPlatformEventTriggerHandler.EventOperation> getQuePayload(String operationType, List<Event> events) {
        List<Google_Calendar_Platform_Event__e> platformEvents = TestDataFactory.createPlatformEvents(eventCount, operationType, events);
        List<GoogleCalPlatformEventTriggerHandler.EventOperation> eventOperations = new List<GoogleCalPlatformEventTriggerHandler.EventOperation>();

        for (Google_Calendar_Platform_Event__e ple : platformEvents) {
            GoogleCalPlatformEventTriggerHandler.EventDeserialize event = (GoogleCalPlatformEventTriggerHandler.EventDeserialize) JSON.deserialize(ple.Salesforce_Event_JSON__c.replaceAll('__c', ''), GoogleCalPlatformEventTriggerHandler.EventDeserialize.class);

            eventOperations.add(new GoogleCalPlatformEventTriggerHandler.EventOperation(event, operationType));
        }

        return eventOperations;
    }

    public class RequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String bodyAsString;

        public RequestMock(Integer code, String body) {
            this.code = code;
            this.bodyAsString = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);

            if (bodyAsString != null) resp.setBody(bodyAsString);

            return resp;
        }
    }

    public class MultiRequestMock implements HttpCalloutMock {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();

        public MultiRequestMock() {
        }

        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpCalloutMock mock = requests.get(req.getMethod());
            if (mock != null) {
                return mock.respond(req);
            } else {
                System.debug('HTTP callout not supported for test methods');
                return null;
            }
        }

        public void addMock(String method, RequestMock mock) {
            this.requests.put(method, mock);
        }
    }

}