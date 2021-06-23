/**
 * Created by Vladyslav Kravchuk on 6/23/2021.
 */

public with sharing class CalendarApi {
    private String calendarId;
    private static final String CALENDAR = 'calendar';
    private static final String EVENTS = 'events';

    private static final Map<String, String> apiEndpoints = new Map<String, String>{
            CALENDAR => 'callout:Google_Calendar/users/me/calendarList',
            EVENTS => 'callout:Google_Calendar/calendars/{0}/events' // {0} - calendarId
    };

    public CalendarApi(String calendarId) {
        this.calendarId = calendarId;
    }

    public HttpResponse getCalendarList() {
        return new CalloutClient(apiEndpoints.get(CALENDAR)).get();
    }

    public HttpResponse getEventList() {
        String endpoint = this.formatRequestEndpoint(EVENTS);
        return new CalloutClient(endpoint).get();
    }

    public HttpResponse insertEvent(Blob eventBody) {
        String endpoint = this.formatRequestEndpoint(EVENTS);

        //JSON.serialize(new Map<String,Object>{'csrNumber'=>'csrNumber','intakeNumber'=>'intakeNumber','notificationRemarks'=>'notificationRemarks','inputContext'=>'inputContext'})
        return new CalloutClient(endpoint).post(eventBody);
    }

    private String formatRequestEndpoint(String endpointName) {
        String endpoint = apiEndpoints.get(endpointName);

        if (endpoint == null) {
            throw new CalendarApiException('No such endpointName ' + endpointName);
        }

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId
        });

        return formatEndpoint;
    }

    public class CalendarApiException extends Exception {
    }
//////////////////////////////////////////////////////////////////////////////
    public class Example {
        public List<String> errors;
        public String message;
        public Detail details;

    }

    public class Detail {
        Id record;
        String record_type;
    }

}