/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class GoogleCalendarCalloutQueue implements Queueable, Database.AllowsCallouts {
    private CalendarApi calendarApi = new CalendarApi('201qazz@gmail.com');
    private List<Event> salesforceEventsToUpdate = new List<Event>();
    private List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEvents;

    public GoogleCalendarCalloutQueue(List<GoogleCalPlatformEventTriggerHandler.EventOperation> platformEvents) {
        this.platformEvents = platformEvents;
    }

    public void execute(QueueableContext context) {
        for (GoogleCalPlatformEventTriggerHandler.EventOperation ple : platformEvents) {
            this.executeCallout(ple.eventJSON, ple.operationType, ple.googleEventId);
        }

        if (!salesforceEventsToUpdate.isEmpty()) Database.upsert(salesforceEventsToUpdate, false);

        System.debug('GoogleCalendarCalloutQueue => salesforceEventsToUpdate= ' + salesforceEventsToUpdate);
    }

    private void executeCallout(String eventJSON, String operationType, String googleEventId) {
        HttpResponse httpResponse = new HttpResponse();
        String requestBody;
        EventDeserialize parsedEvent;

        try {
            // event=null- when operation is DELETE
            if (eventJSON != null) {
                parsedEvent = (EventDeserialize) JSON.deserialize(eventJSON, EventDeserialize.class);

                requestBody = new GoogleCalendarEventBodyGenerator(
                        parsedEvent.Subject,
                        parsedEvent.StartDateTime,
                        parsedEvent.EndDateTime,
                        parsedEvent.Description
                ).toJSON();
            }

            if (operationType == EventOperationType.INSERT_TYPE) {
                httpResponse = this.insertEvent(parsedEvent, requestBody);

            } else if (operationType == EventOperationType.UPDATE_TYPE) {
                httpResponse = this.updateEvent(parsedEvent, requestBody, googleEventId);

            } else if (operationType == EventOperationType.DELETE_TYPE && googleEventId != null) {
                httpResponse = this.deleteEvent(googleEventId);

            } else {

            }
        } catch (System.Exception e) {
            System.debug('#### Exception Executed ' + e.getStackTraceString() + '  ' + e.getMessage());
        }

        System.debug('RESPONSE STATUS IS ' + httpResponse.getStatusCode());
        System.debug('RESPONSE BODY:__' + httpResponse.getBody());
    }

    /////////////// INSERT /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse insertEvent(EventDeserialize salesforceEvent, String requestBody) {
        HttpResponse httpResponse = calendarApi.insertEvent(requestBody);

        if (httpResponse.getStatusCode() == 200) {
            GoogleResponse googleCalendarEvent = (GoogleResponse) JSON.deserialize(httpResponse.getBody(), GoogleResponse.class);
            createSalesforceGoogleEventAssociation(salesforceEvent, googleCalendarEvent.Id);
        }

        return httpResponse;
    }

    /////////////// UPDATE /////////////////////////////////////////////////////////////////////////////////////////////
    private HttpResponse updateEvent(EventDeserialize salesforceEvent, String requestBody, String googleEventId) {
        HttpResponse httpResponse = new HttpResponse();

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
    private void createSalesforceGoogleEventAssociation(EventDeserialize salesforceEvent, String googleEventId) {
        salesforceEventsToUpdate.add(new Event(Id = salesforceEvent.Id, Google_Event_Id__c = googleEventId));
    }

    public class EventDeserialize {
        public String Id;
        public String Subject;
        public String StartDateTime;
        public String EndDateTime;
        public String Description;
    }

    public class GoogleResponse {
        public String Id;
    }

    public class GoogleCalendarInteractionException extends Exception {
    }
}