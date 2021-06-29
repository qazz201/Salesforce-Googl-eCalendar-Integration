/**
 * Created by Vladyslav Kravchuk on 6/23/2021.
 */

public with sharing class CalendarApi {
    private String calendarId;
    private static final String CALLOUT = 'callout:Google_Calendar';

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
        return new CalloutClient(CALLOUT + apiPath.get(CALENDAR)).get();
    }

    public HttpResponse getEventList() {
        String endpoint = this.formatRequestEndpoint(EVENTS);
        return new CalloutClient(endpoint).get();
    }

    //////////// POST ////////////////////////////////////////
    //@future(callout=true)
    public HttpResponse insertEvent(Object eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS);

        // JSON.serialize(new Map<String,Object>{'csrNumber'=>'csrNumber','intakeNumber'=>'intakeNumber','notificationRemarks'=>'notificationRemarks','inputContext'=>'inputContext'})
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
        String endpoint = this.getEndpointByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId
        });

        return CALLOUT + formatEndpoint;
    }

    private String formatRequestEndpoint(String endpointName, String eventId) {
        String endpoint = this.getEndpointByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId, eventId
        });

        return CALLOUT + formatEndpoint;
    }

    private String getEndpointByName(String endpointName) {
        String endpoint = apiPath.get(endpointName);

        if (endpoint == null) {
            throw new CalendarApiException('No such endpointName ' + endpointName);
        }

        return endpoint;
    }

    //////////// EXCEPTION ///////////////////////////////////////
    public class CalendarApiException extends Exception {
    }
}