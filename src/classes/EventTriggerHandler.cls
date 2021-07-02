/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class EventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        List<Google_Calendar_Platform_Event__e> platformEvents = this.getPlatformEventsForInsert(EventOperationType.INSERT_TYPE);
        this.publishPlatformEvent(platformEvents);
    }

    public override void afterUpdate() {
        List<Google_Calendar_Platform_Event__e> platformEvents = this.getPlatformEventsForUpdate(EventOperationType.UPDATE_TYPE);
        this.publishPlatformEvent(platformEvents);
    }

    public override void afterDelete() {
        List<Google_Calendar_Platform_Event__e> platformEvents = this.getPlatformEventsForDelete(EventOperationType.DELETE_TYPE);
        this.publishPlatformEvent(platformEvents);
    }

    private void publishPlatformEvent(List<Google_Calendar_Platform_Event__e> platformEvents) {
        if (!platformEvents.isEmpty()) EventBus.publish(platformEvents);

        System.debug('PLATFORM EVENTS SIZE= ' + platformEvents.size() + ' Platform events: ' + platformEvents);
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    private List<Google_Calendar_Platform_Event__e> getPlatformEventsForInsert(String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();

        for (Event event : (List<Event>) Trigger.new) {
            Google_Calendar_Platform_Event__e platformEvent = createPlatformEventObj(event, operationType);
            platformEvents.add(platformEvent);

            System.debug('Operation is: ' + operationType);
        }

        return platformEvents;
    }

    private List<Google_Calendar_Platform_Event__e> getPlatformEventsForUpdate(String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();
        Map<Id, Event> oldEventsMap = (Map<Id, Event>) Trigger.oldMap;

        for (Event event : (List<Event>) Trigger.new) {
            Event oldEvent = oldEventsMap.get(event.Id);

            // create platform event if one of the fields has been changed
            if (this.isEventChanged(event, oldEvent)) {
                Google_Calendar_Platform_Event__e platformEvent = createPlatformEventObj(event, operationType);
                platformEvents.add(platformEvent);

                System.debug('Operation is: ' + operationType);
            }
        }

        return platformEvents;
    }

    private List<Google_Calendar_Platform_Event__e> getPlatformEventsForDelete(String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();

        for (Event event : (List<Event>) Trigger.old) {
            if (event.Google_Event_Id__c == null) continue; // The deleted event is not present in the google calendar

            Google_Calendar_Platform_Event__e platformEvent = createPlatformEventObj(event, operationType);
            platformEvents.add(platformEvent);

            System.debug('Operation is: ' + operationType);
        }

        return platformEvents;
    }

    private Boolean isEventChanged(Event event, Event oldEvent) {
        if (oldEvent == null) return true; // event was created

        if (event.Subject != oldEvent.Subject
                || event.Description != oldEvent.Description
                || event.StartDateTime != oldEvent.StartDateTime
                || event.EndDateTime != oldEvent.EndDateTime) {
            return true;
        }

        return false;
    }

    private Google_Calendar_Platform_Event__e createPlatformEventObj(Event event, String operationType) {
        return new Google_Calendar_Platform_Event__e(
                Salesforce_Event_JSON__c = JSON.serialize(event),
                Google_Event_Id__c = event.Google_Event_Id__c,
                Operation_Type__c = operationType);
    }

///////////////////// EXCEPTION ////////////////////////////////////////////////////////////////////////////////////
    public class EventTriggerHandlerException extends Exception {
    }
}