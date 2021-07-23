/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

@IsTest
private class GoogleCalPlatformEventTriggerHandlerTest {
    private static final Integer eventCount = 350;

    @TestSetup
    static void setup() {
        List<Event> events = TestDataFactory.createEvents(eventCount);
        insert events;
    }

    @IsTest
    static void afterInsertChunkTest() {
        // Integer totalPlatformEventCount = 110;
        Integer allowedEventCountInChunk = GoogleCalPlatformEventTriggerHandler.calloutChunkSize;
        Integer expectedChunkGroupSize = getChunkGroupSize(allowedEventCountInChunk, eventCount);

        List<Google_Calendar_Platform_Event__e> platformEvents = TestDataFactory.createPlatformEvents(eventCount, EventOperationType.INSERT_TYPE, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, setRequestMocks());

        List<Database.SaveResult> sr = EventBus.publish(platformEvents);
        Test.getEventBus().deliver();
        Test.stopTest();

        System.assertEquals(true, areAllEventsPublishedSuccessful(sr));
        System.assertEquals(expectedChunkGroupSize, GoogleCalPlatformEventTriggerHandler.chunkedPlatformEventsList.size(), 'Chunks should be equal');

        System.debug('EXPECTED ' + expectedChunkGroupSize + ' ACTUAL ' + GoogleCalPlatformEventTriggerHandler.chunkedPlatformEventsList);
    }

    @IsTest
    static void queueResultTest() {
        Integer allowedEventCountInChunk = GoogleCalPlatformEventTriggerHandler.calloutChunkSize;
        Integer expectedChunkGroupSize = getChunkGroupSize(allowedEventCountInChunk, eventCount);

        List<Event> events = getEventList(eventCount);

        List<Google_Calendar_Platform_Event__e> platformEvents = TestDataFactory.createPlatformEvents(eventCount, EventOperationType.INSERT_TYPE, events);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, setRequestMocks());

        EventBus.publish(platformEvents);

        for (Integer i = 0; i < expectedChunkGroupSize; i++) {
            Test.getEventBus().deliver();

            EventBusSubscriber ss = [
                    SELECT Name, Position, Topic
                    FROM EventBusSubscriber
                    WHERE Topic = 'Google_Calendar_Platform_Event__e'
            ];

            System.debug('SSSSSSSSSSSSSSSSSSSSS' + ss);
        }

        Test.stopTest();

        List<Event> eventsUpdated = getEventList(eventCount);

        System.assertEquals(false, areAllEventsHaveGoogleId(events), 'Events should not have Google event Id');
        System.assertEquals(true, areAllEventsHaveGoogleId(eventsUpdated), 'Events should have Google event Id');
    }

//    @IsTest
//    static void queueStressTest() {
//        publishPlatformEvents(10);
//    }
//
//    private static void publishPlatformEvents(Integer count) {
//        List<Event> events = TestDataFactory.createEvents(count);
//        insert events;
//
//        System.debug('AAAAAAAAA' + events[0]);
//        List<Google_Calendar_Platform_Event__e> platformEvents = TestDataFactory.createPlatformEvents(count, EventOperationType.INSERT_TYPE, events);
//
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, setRequestMocks());
//
//        EventBus.publish(platformEvents);
//        Test.getEventBus().deliver();
//
//        Test.stopTest();
//
//        List<Event> eventsUpdated = getEventList();
//
//        System.debug('BBBBBBBBBBBBBBB' + eventsUpdated[0].Google_Event_Id__c);
////        System.assertEquals(false, areAllEventsHaveGoogleId(events), 'Events should not have Google event Id');
////        System.assertEquals(true, areAllEventsHaveGoogleId(eventsUpdated), 'Events should have Google event Id');
//    }

    private static Integer getChunkGroupSize(Integer allowedEventCount, Integer customEventCount) {
        Decimal chunksCount = (Decimal) customEventCount / allowedEventCount;

        return (Integer) chunksCount.round(System.RoundingMode.UP);
    }

    private static Boolean areAllEventsPublishedSuccessful(List<Database.SaveResult> publishResults) {
        for (Database.SaveResult sr : publishResults) {
            if (!sr.isSuccess()) return false;
        }
        return true;
    }

    private static List<Event> getEventList(Integer count) {
        Set<String> evFieldList = Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap().keySet();
        List<String> strList = new List<String>(evFieldList);
        String fields = string.join(strList, ',');

        String queryString = 'SELECT ' + fields + ' FROM Event';

        if (count != null) {
            queryString = queryString + ' Limit ' + count;
        }

        return Database.query(queryString);
    }

    private static Boolean areAllEventsHaveGoogleId(List<Event> events) {
        for (Event event : events) {
            System.debug('AAAAAAAAAAAA= ' + event.Google_Event_Id__c + ' ___ ' + event);
            if (event.Google_Event_Id__c == null) return false;
        }
        return true;
    }

    private static MultiRequestMock setRequestMocks() {
        RequestMock mimicGETResp = new RequestMock(200, mockGETResponse());
        RequestMock mimicPOSTResp = new RequestMock(200, mockPOSTResponse());

        MultiRequestMock multiRequestMock = new MultiRequestMock();
        multiRequestMock.addMock('GET', mimicGETResp);
        multiRequestMock.addMock('POST', mimicPOSTResp);

        return multiRequestMock;
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