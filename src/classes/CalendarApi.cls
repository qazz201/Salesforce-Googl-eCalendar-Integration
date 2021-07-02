/**
 * Created by Vladyslav Kravchuk on 6/23/2021.
 */

public with sharing class CalendarApi {
    private String calendarId;
    private static final String ROOT_PATH = 'callout:Google_Calendar';

    private static final String CALENDAR = 'calendar';
    private static final String EVENTS = 'events';
    private static final String EVENTS_CHANGE = 'eventsChange';

    private static final Map<String, String> apiPath = new Map<String, String>{
            CALENDAR => '/users/me/calendarList',
            EVENTS => '/calendars/{0}/events', // {0} - calendarId (GET,POST)
            EVENTS_CHANGE => '/calendars/{0}/events/{1}' //{0} - calendarId; {1} -eventId (DELETE,PUT)
    };

    public CalendarApi() {
    }

    public CalendarApi(String calendarId) {
        this.calendarId = calendarId;
    }

    //////////// GET ////////////////////////////////////////
    public HttpResponse getCalendarList() {
        return new CalloutClient(ROOT_PATH + apiPath.get(CALENDAR)).get();
    }

    public HttpResponse getEventList() {
        String endpoint = this.formatRequestEndpoint(EVENTS);
        return new CalloutClient(endpoint).get();
    }

    public String getOwnerCalendarId() {
        String calendarId;

        String responseBody = this.getCalendarList().getBody();
        CalendarListResponse parsedBody = (CalendarListResponse) JSON.deserialize(responseBody, CalendarListResponse.class);

        for (CalendarListItems calendar : parsedBody.items) {
            System.debug('ACCESSROLE IS= ' + calendar.accessRole + ' CALENDAR ID IS ' + calendar.Id);

            if (calendar.accessRole.toLowerCase() == 'owner') {
                calendarId = calendar.Id;
                break;
            }
        }

        return calendarId;
    }

    //////////// POST ////////////////////////////////////////
    public HttpResponse insertEvent(Object eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS);
        return new CalloutClient(endpoint).post(eventBody);
    }

    //////////// DELETE ////////////////////////////////////////
    public HttpResponse deleteEvent(String eventId) {
        String endpoint = this.formatRequestEndpoint(EVENTS_CHANGE, eventId);
        return new CalloutClient(endpoint).del();
    }

    //////////// PUT //////////////////////////////////////////
    public HttpResponse updateEventPUT(String eventId, Object eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS_CHANGE, eventId);
        return new CalloutClient(endpoint).put(eventBody);
    }

    //////////// PATCH //////////////////////////////////////////
    public HttpResponse updateEventPATCH(String eventId, Object eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS_CHANGE, eventId);
        return new CalloutClient(endpoint).patch(eventBody);
    }

    //////////// UTILITY //////////////////////////////////////
    private String formatRequestEndpoint(String endpointName) {
        String endpoint = this.getPathByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId
        });

        return ROOT_PATH + formatEndpoint;
    }

    private String formatRequestEndpoint(String endpointName, String eventId) {
        String endpoint = this.getPathByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId, eventId
        });

        return ROOT_PATH + formatEndpoint;
    }

    private String getPathByName(String name) {
        String path = apiPath.get(name);

        if (path == null) {
            throw new CalendarApiException('No such path name: ' + name);
        }

        return path;
    }

    public class CalendarListResponse {
        public List<CalendarListItems> items;
    }

    public class CalendarListItems {
        public String Id;
        public String accessRole;
    }

    //////////// EXCEPTION ///////////////////////////////////////
    public class CalendarApiException extends Exception {
    }
}