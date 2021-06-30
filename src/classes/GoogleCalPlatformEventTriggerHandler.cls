/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public with sharing class GoogleCalPlatformEventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        List<EventOperation> eventOperations = new List<EventOperation>();
        Map<Id, Event> eventByIds = this.getEventByIds();

        for (Google_Calendar_Platform_Event__e ple : (List<Google_Calendar_Platform_Event__e>) Trigger.new) {
            Event event;
            String operationType = ple.Operation_Type__c;
            String googleEventId = ple.Google_Event_Id__c;

            // If operation DELETE- there is no Event can be found via SOQL
            if (operationType != PlatformEventTypes.DELETE_TYPE) event = eventByIds.get(ple.Salesforce_Event_Id__c);

            eventOperations.add(new EventOperation(event, operationType, googleEventId));
        }

        System.enqueueJob(new GoogleCalendarCalloutService(eventOperations));
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    /**
     *  Get salesforce events from platform event
     * @return
     */
    private Map<Id, Event> getEventByIds() {
        List<Id> eventsId = new List<Id>();

        for (Google_Calendar_Platform_Event__e ple : (List <Google_Calendar_Platform_Event__e>) Trigger.new) {
            eventsId.add(ple.Salesforce_Event_Id__c);
        }

        Map<Id, Event> events = new Map<Id, Event> ([
                SELECT Id,
                        Subject,
                        StartDateTime,
                        EndDateTime,
                        Description
                FROM Event
                WHERE Id IN :eventsId
        ]);

        return events;
    }

    public class EventOperation {
        public Event event;
        public String operationType;
        public String googleEventId;

        public EventOperation(Event event, String operationType, String googleEventId) {
            this.event = event;
            this.operationType = operationType;
            this.googleEventId = googleEventId;
        }
    }

    public class GoogleCalPlatformEventTriggerHandlerException extends Exception {
    }
}