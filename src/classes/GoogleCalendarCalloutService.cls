/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class GoogleCalendarCalloutService implements Queueable, Database.AllowsCallouts {
    private CalendarApi calendarApi = new CalendarApi('201qazz@gmail.com');
    private List<Google_Calendar_Event__c> googleEventsToInsert = new List<Google_Calendar_Event__c>();
    private List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEvents;

    public GoogleCalendarCalloutService(List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEvents) {
        this.platformEvents = platformEvents;
    }

    public void execute(QueueableContext context) {
        for (GoogleCalPlatformEventTriggerHandler.EventOperation ple : platformEvents) {
            this.executeCallout(ple.event, ple.operationType);
        }

        insert googleEventsToInsert;
    }

    private void executeCallout(Event event, String operationType) {
        HttpResponse httpResponse = new HttpResponse();
        String requestBody = new GoogleCalendarEventBodyGenerator(
                event.Subject,
                event.StartDateTime,
                event.EndDateTime,
                event.Description
        ).toJSON();

        if (operationType == PlatformEventTypes.INSERT_TYPE) {
            httpResponse = insertEvent(event, requestBody);

        } else if (operationType == PlatformEventTypes.UPDATE_TYPE) {
            httpResponse = updateEvent(event, requestBody);

        } else if (operationType == PlatformEventTypes.DELETE_TYPE) {

        } else {

        }

        System.debug('RESPONSE STATUS IS ' + httpResponse.getStatusCode());
        System.debug('RESPONSE BODY:__' + httpResponse.getBody());
    }

    /////////////// INSERT /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse insertEvent(Event salesforceEvent, String requestBody) {
        HttpResponse httpResponse = calendarApi.insertEvent(requestBody);

        if (httpResponse.getStatusCode() == 200) {
            GoogleResponse googleCalendarEvent = (GoogleResponse) JSON.deserialize(httpResponse.getBody(), GoogleResponse.class);
            createSalesforceGoogleEventAssociation(salesforceEvent.Id, googleCalendarEvent.Id);
        }

        return httpResponse;
    }

    /////////////// UPDATE /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse updateEvent(Event salesforceEvent, String requestBody) {
        String googleEventId = getGoogleEventIdBySalesforceEventId(salesforceEvent.Id);
        HttpResponse httpResponse = new HttpResponse();

        if (googleEventId == null) {
            httpResponse = this.insertEvent(salesforceEvent, requestBody);
        } else {
            httpResponse = calendarApi.updateEventPUT(googleEventId, requestBody);
        }

        return httpResponse;
    }


    /////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////////////
    private void createSalesforceGoogleEventAssociation(String salesforceEventId, String googleEventId) {
        googleEventsToInsert.add(new Google_Calendar_Event__c(
                Salesforce_Event_Id__c = salesforceEventId,
                Google_Event_Id__c = googleEventId
        ));
    }

    private static String getGoogleEventIdBySalesforceEventId(String salesforceEventId) {
        List<Google_Calendar_Event__c> googleCalendarEvents = [
                SELECT
                        Id,
                        Salesforce_Event_Id__c,
                        Google_Event_Id__c
                from Google_Calendar_Event__c
                WHERE Salesforce_Event_Id__c = :salesforceEventId
        ];

        if (!googleCalendarEvents.isEmpty()) return googleCalendarEvents[0].Google_Event_Id__c;
        return null;
    }

    public class GoogleResponse {
        public String Id;
    }

    public class GoogleCalendarInteractionException extends Exception {
    }
}