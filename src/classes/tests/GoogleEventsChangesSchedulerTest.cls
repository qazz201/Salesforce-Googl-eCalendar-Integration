/**
 * Created by Vladyslav Kravchuk on 7/28/2021.
 */

@IsTest
private class GoogleEventsChangesSchedulerTest {
    private static final String JOB_NAME = 'Batch Scheduler';

    @IsTest
    static void scheduleTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, setRequestMocks());

        System.schedule(JOB_NAME, '0 0 3 ? * *', new GoogleEventsChangesScheduler());
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [
                SELECT
                        Id
                        , ApexClassID
                        , ApexClass.Name
                        , Status
                        , JobType
                FROM AsyncApexJob
                WHERE JobType = 'ScheduledApex'
        ];

        System.assertEquals(false, jobsScheduled.isEmpty(), 'Expecting one scheduled job');
        System.assert(GoogleEventsChangesScheduler.class.getName().contains(jobsScheduled[0].ApexClass.Name));
    }

    @IsTest
    static void calloutTest() {
        List<Event> eventsBefore = [SELECT Id FROM Event];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, setRequestMocks());
        GoogleEventsChangesScheduler.syncEventsFromGoogle();
        Test.stopTest();

        List<Event> eventsAfter = [SELECT Id FROM Event];

        System.assertEquals(true, eventsBefore.isEmpty(), 'No events before the batch run');
        System.assertEquals(false, eventsAfter.isEmpty(), 'Events should be created');
    }

    private static MultiRequestMock setRequestMocks() {
        RequestMock mimicGETResp = new RequestMock(200, mockGETCalendarIdResponse());
        RequestMock mimicCalendarEventChanges = new RequestMock(200, mockGETCalendarEventsChangesResponse());

        MultiRequestMock multiRequestMock = new MultiRequestMock();
        multiRequestMock.addMock(mimicGETResp);
        multiRequestMock.addMock(mimicCalendarEventChanges);
        multiRequestMock.addMock(mimicCalendarEventChanges);

        return multiRequestMock;
    }

    private static String mockGETCalendarIdResponse() {
        return '{"items": [' +
                '  {' +
                '   "id": "test@gmail.com",' +
                '   "accessRole": "owner"' +
                '}]' +
                '}';
    }

    private static String mockGETCalendarEventsChangesResponse() {
        return '{' +
                ' "nextSyncToken": "CKDp0p_Gp_ICEKDp9p_Gg_pCGAUg07iMuAE",' +
                ' "items": [' +
                '  {' +
                '   "id": "3r4f",' +
                '   "status": "confirmed",' +
                '   "summary": "SUMMERY_1",' +
                '   "description": "DESC_1",' +
                '   "start": {' +
                '    "dateTime": "2021-07-27T03:00:00+03:00"' +
                '   },' +
                '   "end": {' +
                '    "dateTime": "2021-07-27T04:00:00+03:00"' +
                '   }' +
                '  },' +
                '  {' +
                '   "id": "3r4d",' +
                '   "status": "confirmed",' +
                '   "summary": "SUMMERY_2",' +
                '   "description": "DESC_2",' +
                '   "start": {' +
                '    "dateTime": "2021-07-27T03:00:00+03:00"' +
                '   },' +
                '   "end": {' +
                '    "dateTime": "2021-07-27T04:00:00+03:00"' +
                '   }' +
                '  }' +
                ' ]' +
                '}';
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
        private List<HttpCalloutMock> requests = new List<HttpCalloutMock>();
        private Integer counter = 0;

        public MultiRequestMock() {
        }

        public MultiRequestMock(List<HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpCalloutMock mock = requests[counter];
            if (mock != null) {
                counter++;
                return mock.respond(req);
            } else {
                System.debug('HTTP callout not supported for test methods');
                return null;
            }
        }

        public void addMock(RequestMock mock) {
            this.requests.add(mock);
        }
    }
}