/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class GoogleCalendarInteraction {
    private static Google_Platform_Event_Type__mdt platformEventTypes;

    static {
        platformEventTypes = getGooglePlatformEventTypes();
    }

    public static void insertEvent(Event salesforceEvent) {
        executeCallout(JSON.serialize(salesforceEvent), platformEventTypes.Event_Insert__c, null);
    }

    public static void updateEvent(Event salesforceEvent) {
        String googleEventId = getGoogleEventIdBySalesforceEventId(salesforceEvent.Id);

        if (googleEventId != null) {
            executeCallout(JSON.serialize(salesforceEvent), platformEventTypes.Event_Update__c, googleEventId);
        } else {
            insertEvent(salesforceEvent);
        }
    }

    public static void deleteEvent(Event salesforceEvent) {
        executeCallout(JSON.serialize(salesforceEvent), platformEventTypes.Event_Delete__c, null);
    }

    @Future(callout=true)
    public static void executeCallout(String eventBody, String operationType, String googleEventId) {
        System.debug('OPERATION == ' + operationType + '; _PLATFORM EVENTS TYPE_=' + platformEventTypes);
        System.debug('GOOGLE EVENT ID= ' + googleEventId);

        SalesforceEvent ev = (SalesforceEvent) JSON.deserialize(eventBody, SalesforceEvent.class);
        HttpResponse httpResponse = new HttpResponse();

        if (operationType == platformEventTypes.Event_Insert__c) {
            httpResponse = new CalendarApi('201qazz@gmail.com').insertEvent('{' +
                    '"summary":"' + ev.Subject + '",' +
                    ' "start": {' +
                    '    "dateTime":"' + ev.StartDateTime + '"' +
                    '  },' +
                    '  "end": {' +
                    '    "dateTime":"' + ev.EndDateTime + '"' +
                    '  }' +
                    '}');

            if (httpResponse.getStatusCode() == 200) {
                GoogleResponse googleParseResp = (GoogleResponse) JSON.deserialize(httpResponse.getBody(), GoogleResponse.class);
                createSalesforceGoogleEventAssociation(ev.Id, googleParseResp.Id);
            }

        } else if (operationType == platformEventTypes.Event_Update__c) {
            if (googleEventId == null) throw new GoogleCalendarInteractionException('You must provide Google event Id');

            httpResponse = new CalendarApi('201qazz@gmail.com').updateEventPUT(googleEventId, '{' +
                    '"summary":"' + ev.Subject + '",' +
                    ' "start": {' +
                    '    "dateTime":"' + ev.StartDateTime + '"' +
                    '  },' +
                    '  "end": {' +
                    '    "dateTime":"' + ev.EndDateTime + '"' +
                    '  }' +
                    '}');
            System.debug('RESPONSE STATUS IS ' + httpResponse.getStatusCode());
        } else if (operationType == platformEventTypes.Event_Delete__c) {

        } else {

        }

        System.debug('RESPONSE BODY:__' + httpResponse.getBody());
    }

    /////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////////////
    private static void createSalesforceGoogleEventAssociation(String salesforceEventId, String googleEventId) {
        insert new Google_Calendar_Event__c(
                Salesforce_Event_Id__c = salesforceEventId,
                Google_Event_Id__c = googleEventId
        );
    }

    private static String getGoogleEventIdBySalesforceEventId(String salesforceEventId) {
        List<Google_Calendar_Event__c> googleCalendarEvents = [SELECT Id,Salesforce_Event_Id__c,Google_Event_Id__c from Google_Calendar_Event__c WHERE Salesforce_Event_Id__c = :salesforceEventId];

        if (!googleCalendarEvents.isEmpty()) return googleCalendarEvents[0].Google_Event_Id__c;
        return null;
    }

    private static Google_Platform_Event_Type__mdt getGooglePlatformEventTypes() {
        List<Google_Platform_Event_Type__mdt> eventType = [
                SELECT Is_Active__c,
                        Event_Insert__c,
                        Event_Update__c,
                        Event_Delete__c
                FROM Google_Platform_Event_Type__mdt
                WHERE Is_Active__c = TRUE
        ];

        if (!eventType.isEmpty()) {
            return eventType[0];
        }

        return null;
    }

    public class SalesforceEvent {
        public String Id;
        public String Subject;
        public String StartDateTime;
        public String EndDateTime;
    }

    public class GoogleResponse {
        public String Id;
    }

    public class GoogleCalendarInteractionException extends Exception {
    }
}