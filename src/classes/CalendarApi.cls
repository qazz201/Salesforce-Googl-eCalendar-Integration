/**
 * Created by Vladyslav Kravchuk on 6/23/2021.
 */

public with sharing class CalendarApi {
    private String calendarId;
    private static final String CALENDAR = 'calendar';
    private static final String EVENTS = 'events';
    private static final String EVENTS_CHANGE = 'eventsDelete';

    private static final Map<String, String> apiEndpoints = new Map<String, String>{
            CALENDAR => 'callout:Google_Calendar/users/me/calendarList',
            EVENTS => 'callout:Google_Calendar/calendars/{0}/events', // {0} - calendarId (GET,POST)
            EVENTS_CHANGE => 'callout:Google_Calendar/calendars/{0}/events/{1}' //{0} - calendarId; {1} -eventId (DELETE,PUT)
    };

    public CalendarApi(String calendarId) {
        this.calendarId = calendarId;
    }

    //////////// GET ////////////////////////////////////////
    public HttpResponse getCalendarList() {
        return new CalloutClient(apiEndpoints.get(CALENDAR)).get();
    }

    public HttpResponse getEventList() {
        String endpoint = this.formatRequestEndpoint(EVENTS);
        return new CalloutClient(endpoint).get();
    }

    //////////// POST ////////////////////////////////////////
    public HttpResponse insertEvent(Object eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS);

        //JSON.serialize(new Map<String,Object>{'csrNumber'=>'csrNumber','intakeNumber'=>'intakeNumber','notificationRemarks'=>'notificationRemarks','inputContext'=>'inputContext'})
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

        return formatEndpoint;
    }

    private String formatRequestEndpoint(String endpointName, String eventId) {
        String endpoint = this.getEndpointByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId, eventId
        });

        return formatEndpoint;
    }

    private String getEndpointByName(String endpointName) {
        String endpoint = apiEndpoints.get(endpointName);

        if (endpoint == null) {
            throw new CalendarApiException('No such endpointName ' + endpointName);
        }

        return endpoint;
    }

    //////////// EXCEPTION ///////////////////////////////////////
    public class CalendarApiException extends Exception {
    }

}