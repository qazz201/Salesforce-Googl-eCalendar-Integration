/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public with sharing class GoogleCalPlatformEventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {

        Map<Id, Event> eventByIds = this.getEventByIds();
        List<EventOperation> eventOperations = new List<EventOperation>();

        for (Google_Calendar_Platform_Event__e ple : (List<Google_Calendar_Platform_Event__e>) Trigger.new) {
            Event event = eventByIds.get(ple.Salesforce_Event_Id__c);
            String operationType = ple.Operation_Type__c;

            eventOperations.add(new EventOperation(event, operationType));
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

        if (!events.isEmpty()) return events;

        return null;
    }

    public class EventOperation {
        public Event event;
        public String operationType;

        public EventOperation(Event event, String operationType) {
            this.event = event;
            this.operationType = operationType;
        }
    }

    public class GoogleCalPlatformEventTriggerHandlerException extends Exception {
    }
}