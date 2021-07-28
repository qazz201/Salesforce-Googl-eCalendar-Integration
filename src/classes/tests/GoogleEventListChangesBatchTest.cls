/**
 * Created by Vladyslav Kravchuk on 7/28/2021.
 */

@IsTest
private class GoogleEventListChangesBatchTest {
//    private static final String previousSyncToken = 'CKDp0p_Gp_ICEKDp9p_Gg_pCGAUg07iMuAE=';
//    private static final String nextSyncToken = 'MKDp0p_Gp_ICEKDp9p_Gg_pCGAUg07iMuAE=';
//
//    @TestSetup
//    static void setup() {
//        insert new Account(Name = 'Account_1');
//
//        insert new Google_Calendar_Events_Sync_Token__c(
//                Name = previousSyncToken,
//                Sync_Token__c = previousSyncToken,
//                Active__c = true);
//    }
//
//    @IsTest
//    static void batchTest() {
//        List<Event> eventsBefore = [SELECT Id FROM Event];
//
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, setRequestMocks());
//        Database.executeBatch(new GoogleEventListChangesBatch());
//        Test.stopTest();
//
//        List<Event> eventsAfter = [SELECT Id FROM Event];
//
//        System.assertEquals(true, eventsBefore.isEmpty(), 'No events before the batch run');
//        System.assertEquals(false, eventsAfter.isEmpty(), 'Events should be created');
//
//    }
//
//    private static MultiRequestMock setRequestMocks() {
//        RequestMock mimicGETResp = new RequestMock(200, mockGETCalendarIdResponse());
//        RequestMock mimicPOSTResp = new RequestMock(200, mockGETCalendarEventsChangesResponse());
//
//        MultiRequestMock multiRequestMock = new MultiRequestMock();
//        multiRequestMock.addMock(mimicGETResp);
//        multiRequestMock.addMock(mimicPOSTResp);
//
//        return multiRequestMock;
//    }
//
//    private static String mockGETCalendarIdResponse() {
//        return '{"items": [' +
//                '  {' +
//                '   "id": "test@gmail.com",' +
//                '   "accessRole": "owner"' +
//                '}]' +
//                '}';
//    }
//
//    private static String mockGETCalendarEventsChangesResponse() {
//        return '{' +
//                ' "nextSyncToken": "' + nextSyncToken + '",' +
//                ' "items": [' +
//                '  {' +
//                '   "id": "3r4f",' +
//                '   "status": "confirmed",' +
//                '   "summary": "SUMMERY_1",' +
//                '   "description": "DESC_1",' +
//                '   "start": {' +
//                '    "dateTime": "2021-07-27T03:00:00+03:00"' +
//                '   },' +
//                '   "end": {' +
//                '    "dateTime": "2021-07-27T04:00:00+03:00"' +
//                '   }' +
//                '  },' +
//                '  {' +
//                '   "id": "3r4d",' +
//                '   "status": "confirmed",' +
//                '   "summary": "SUMMERY_2",' +
//                '   "description": "DESC_2",' +
//                '   "start": {' +
//                '    "dateTime": "2021-07-27T03:00:00+03:00"' +
//                '   },' +
//                '   "end": {' +
//                '    "dateTime": "2021-07-27T04:00:00+03:00"' +
//                '   }' +
//                '  }' +
//                ' ]' +
//                '}';
//    }
//
//    public class RequestMock implements HttpCalloutMock {
//        protected Integer code;
//        protected String bodyAsString;
//
//        public RequestMock(Integer code, String body) {
//            this.code = code;
//            this.bodyAsString = body;
//        }
//
//        public HTTPResponse respond(HTTPRequest req) {
//            HttpResponse resp = new HttpResponse();
//            resp.setStatusCode(code);
//
//            if (bodyAsString != null) resp.setBody(bodyAsString);
//
//            return resp;
//        }
//    }
//
//    public class MultiRequestMock implements HttpCalloutMock {
//        private List<HttpCalloutMock> requests = new List<HttpCalloutMock>();
//        private Integer counter = 0;
//
//        public MultiRequestMock() {
//        }
//
//        public MultiRequestMock(List<HttpCalloutMock> requests) {
//            this.requests = requests;
//        }
//
//        public HTTPResponse respond(HTTPRequest req) {
//            HttpCalloutMock mock = requests[counter];
//            if (mock != null) {
//                counter++;
//                return mock.respond(req);
//            } else {
//                System.debug('HTTP callout not supported for test methods');
//                return null;
//            }
//        }
//
//        public void addMock(RequestMock mock) {
//            this.requests.add(mock);
//        }
//    }
}