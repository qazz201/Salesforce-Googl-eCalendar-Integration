/**
 * Created by Vladyslav Kravchuk on 6/23/2021.
 */

public with sharing class CalendarApi {
    private String calendarId;
    private static final String ROOT_PATH = 'callout:Google_Calendar';

    private static final String CALENDAR = 'calendar';
    private static final String EVENTS = 'events';
    private static final String EVENTS_BY_SYNC_TOKEN = 'googleEventsSyncToken'; // Token on event changes
    private static final String EVENTS_CHANGE = 'eventsChange';

    private static final Map<String, String> apiPath = new Map<String, String>{
            CALENDAR => '/users/me/calendarList',
            EVENTS => '/calendars/{0}/events', // {0} - calendarId (GET,POST)
            EVENTS_BY_SYNC_TOKEN => '/calendars/{0}/events?syncToken={1}', // {0} - calendarId; {1}- sync token;
            EVENTS_CHANGE => '/calendars/{0}/events/{1}' //{0} - calendarId; {1} -eventId (DELETE,PUT)
    };

    public CalendarApi() {
        this.calendarId = this.getOwnerCalendarId();
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

    public HttpResponse getEventListChanges() {
        HttpResponse httpResponse = new HttpResponse();
        String syncToken = this.getGoogleEventSyncToken();

        if (syncToken == null) throw new CalendarApiException('No Google event sync token found');

        String endpoint = this.formatRequestEndpoint(EVENTS_BY_SYNC_TOKEN, syncToken);
        httpResponse = new CalloutClient(endpoint).get();

        GoogleEventSyncToken newToken = (GoogleEventSyncToken) JSON.deserialize(httpResponse.getBody(), GoogleEventSyncToken.class);
        this.updateCustomSettingByNameAndSetSyncToken(syncToken, newToken.nextSyncToken); // syncToken as a custom setting name

        return httpResponse;
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

    private String getGoogleEventSyncToken() {
        String syncToken;
        Map<String, Google_Calendar_Events_Sync_Token__c> customSettings = Google_Calendar_Events_Sync_Token__c.getAll();

        if (customSettings.isEmpty()) {
            syncToken = this.getGoogleEventSyncTokenFromGetEventListRequest();
        } else {
            syncToken = this.getGoogleEventSyncTokenFormCustomSetting(customSettings);
        }

        return syncToken;
    }

    private String getGoogleEventSyncTokenFromGetEventListRequest() {
        HttpResponse eventList = this.getEventList();
        GoogleEventSyncToken googleEventSyncToken = (GoogleEventSyncToken) JSON.deserialize(eventList.getBody(), GoogleEventSyncToken.class);

        return googleEventSyncToken.nextSyncToken;
    }

    private String getGoogleEventSyncTokenFormCustomSetting(Map<String, Google_Calendar_Events_Sync_Token__c> customSettings) {
        String syncToken;

        if (customSettings.isEmpty()) {
            String em = 'customSettings should be passed into getGoogleEventSyncTokenFormCustomSetting method';
            System.debug(em);
            throw new CalendarApiException(em);
        }

        for (Google_Calendar_Events_Sync_Token__c gst : customSettings.values()) {
            if (gst.Active__c) {
                syncToken = gst.Sync_Token__c;
                break;
            }
        }
        return syncToken;
    }

    private void updateCustomSettingByNameAndSetSyncToken(String customSettingName, String googleSyncToken) {
        Google_Calendar_Events_Sync_Token__c customSetting = Google_Calendar_Events_Sync_Token__c.getValues(customSettingName);

        if (customSetting == null) {
            insert new Google_Calendar_Events_Sync_Token__c(
                    Name = customSettingName,
                    Sync_Token__c = googleSyncToken,
                    Active__c = true);
            return;
        }

        customSetting.Name = googleSyncToken;
        customSetting.Sync_Token__c = googleSyncToken;
        customSetting.Active__c = true;

        update customSetting;
    }

    private String formatRequestEndpoint(String endpointName, String eventId) {
        String endpoint = this.getPathByName(endpointName);

        String formatEndpoint = String.format(endpoint, new List<String>{
                this.calendarId,
                eventId
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

    public class GoogleEventSyncToken {
        private String nextSyncToken;
    }

    //////////// EXCEPTION ///////////////////////////////////////
    public class CalendarApiException extends Exception {
    }
}