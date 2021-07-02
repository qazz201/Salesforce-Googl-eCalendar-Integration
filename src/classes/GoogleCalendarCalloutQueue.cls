/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class GoogleCalendarCalloutQueue implements Queueable, Database.AllowsCallouts {
    private List<Event> salesforceEventsToUpdate = new List<Event>();
    private List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEvents;
    private CalendarApi calendarApi;

    public GoogleCalendarCalloutQueue(List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEventOperations) {
        this.platformEvents = platformEventOperations;
    }

    public void execute(QueueableContext context) {
        calendarApi = new CalendarApi(this.getCalendarId());

        for (GoogleCalPlatformEventTriggerHandler.EventOperation ple : platformEvents) {
            this.executeCallout(ple.event, ple.operationType);
        }

        if (!salesforceEventsToUpdate.isEmpty()) Database.upsert(salesforceEventsToUpdate, false);

        System.debug('GoogleCalendarCalloutQueue => salesforceEventsToUpdate = ' + salesforceEventsToUpdate);
    }

    private void executeCallout(GoogleCalPlatformEventTriggerHandler.EventDeserialize event, String operationType) {
        HttpResponse httpResponse = new HttpResponse();
        String requestBody;

        try {
            if (event != null) {
                requestBody = new GoogleCalendarEventBodyGenerator(
                        event.Subject,
                        event.StartDateTime,
                        event.EndDateTime,
                        event.Description
                ).toJSON();
            }

            if (operationType == EventOperationType.INSERT_TYPE) {
                httpResponse = this.insertEvent(event, requestBody);

            } else if (operationType == EventOperationType.UPDATE_TYPE) {
                httpResponse = this.updateEvent(event, requestBody);

            } else if (operationType == EventOperationType.DELETE_TYPE && event.Google_Event_Id != null) {
                httpResponse = this.deleteEvent(event.Google_Event_Id);

            } else {

            }
        } catch (System.Exception e) {
            System.debug('#### Exception Executed ' + e.getStackTraceString() + '  ' + e.getMessage());
        }

        System.debug('RESPONSE STATUS IS ' + httpResponse.getStatusCode());
        System.debug('RESPONSE BODY:__' + httpResponse.getBody());
    }

    /////////////// INSERT /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse insertEvent(GoogleCalPlatformEventTriggerHandler.EventDeserialize salesforceEvent, String requestBody) {
        HttpResponse httpResponse = calendarApi.insertEvent(requestBody);

        if (httpResponse.getStatusCode() == 200) {
            GoogleResponse googleCalendarEvent = (GoogleResponse) JSON.deserialize(httpResponse.getBody(), GoogleResponse.class);
            this.setGoogleEventIdInSalesforceEvent(salesforceEvent, googleCalendarEvent.Id);
        }

        return httpResponse;
    }

    /////////////// UPDATE /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse updateEvent(GoogleCalPlatformEventTriggerHandler.EventDeserialize salesforceEvent, String requestBody) {
        HttpResponse httpResponse = new HttpResponse();
        String googleEventId = salesforceEvent.Google_Event_Id;

        if (googleEventId == null) {
            httpResponse = this.insertEvent(salesforceEvent, requestBody);
        } else {
            httpResponse = calendarApi.updateEventPUT(googleEventId, requestBody);
        }

        return httpResponse;
    }

    /////////////// DELETE /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse deleteEvent(String googleEventId) {
        return calendarApi.deleteEvent(googleEventId);
    }

    /////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////////////
    private void setGoogleEventIdInSalesforceEvent(GoogleCalPlatformEventTriggerHandler.EventDeserialize salesforceEvent, String googleEventId) {
        salesforceEventsToUpdate.add(new Event(Id = salesforceEvent.Id, Google_Event_Id__c = googleEventId));
    }

    private String getCalendarId() {
        return new CalendarApi().getOwnerCalendarId();
    }

    public class GoogleResponse {
        public String Id;
    }

    public class GoogleCalendarInteractionException extends Exception {
    }
}