/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class EventTriggerHandler extends TriggerHandler {
    private String operationType;

    public override void afterInsert() {
        this.operationType = PlatformEventTypes.INSERT_TYPE;
        this.publishPlatformEvent();
    }

    public override void afterUpdate() {
        this.operationType = PlatformEventTypes.UPDATE_TYPE;
        this.publishPlatformEvent();
    }

    public override void afterDelete() {
        this.operationType = PlatformEventTypes.DELETE_TYPE;
        this.publishPlatformEvent();
    }

    private void publishPlatformEvent() {
        List<Google_Calendar_Platform_Event__e> platformEvents = collectPlatformEvents(operationType);

        if (!platformEvents.isEmpty()) EventBus.publish(platformEvents);

        System.debug('PLATFORM EVENTS SIZE= ' + platformEvents.size() + ' EMPTY? ' + platformEvents.isEmpty() + ' Platform events: ' + platformEvents);
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    private List<Google_Calendar_Platform_Event__e> collectPlatformEvents(String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();
        Map<Id, Event> oldEventsMap = (Map<Id, Event>) Trigger.oldMap;
        List<Event> triggerContext;

        if (operationType == PlatformEventTypes.INSERT_TYPE || operationType == PlatformEventTypes.UPDATE_TYPE) {
            triggerContext = (List<Event>) Trigger.new;
        } else if (operationType == PlatformEventTypes.DELETE_TYPE) {
            triggerContext = (List<Event>) Trigger.old;
        }

        for (Event event : triggerContext) {
            Boolean allowPlatformEvent = allowPlatformEvent(event, oldEventsMap);
            System.debug('Allow Platform Events? ' + allowPlatformEvent + ' Operation is: ' + operationType);

            // TODO: Change this logic
            if (allowPlatformEvent) {
                platformEvents.add(new Google_Calendar_Platform_Event__e(
                        Salesforce_Event_Id__c = event.Id,
                        Google_Event_Id__c = event.Google_Event_Id__c,
                        Operation_Type__c = operationType)
                );
            }
        }
        return platformEvents;
    }

    // TODO: Change this logic ( run trigger logic if one of the fields was updated )
    private Boolean allowPlatformEvent(Event newEvent, Map<Id, Event> oldEventsMap) {
        if (oldEventsMap == null) return true; // Creation of new record

        Event oldEvent = oldEventsMap.get(newEvent.Id);

        // Allow trigger run if the operation is DELETE or
        // if one of the fields has been changed
        if (newEvent.Subject != oldEvent.Subject
                || newEvent.Description != oldEvent.Description
                || newEvent.StartDateTime != oldEvent.StartDateTime
                || newEvent.EndDateTime != oldEvent.EndDateTime) {
            return true;
        } else if (operationType == PlatformEventTypes.DELETE_TYPE) {
            if (newEvent.Google_Event_Id__c == null) return false; // The deleted event is not present in the google calendar
            return true;
        }
        return false;
    }

///////////////////// EXCEPTION ////////////////////////////////////////////////////////////////////////////////////
    public class EventTriggerHandlerException extends Exception {
    }
}