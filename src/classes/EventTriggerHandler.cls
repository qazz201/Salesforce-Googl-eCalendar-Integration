/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class EventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        List<Event> eventList = this.eventsForInsert();
        List<Google_Calendar_Platform_Event__e> platformEvents = this.createPlatformEvents(eventList, EventOperationType.INSERT_TYPE);

        this.publishPlatformEvents(platformEvents);
    }

    public override void afterUpdate() {
        List<Event> eventList = this.eventsForUpdate();
        List<Google_Calendar_Platform_Event__e> platformEvents = this.createPlatformEvents(eventList, EventOperationType.UPDATE_TYPE);

        this.publishPlatformEvents(platformEvents);
    }

    public override void afterDelete() {
        List<Event> eventList = this.eventsForDelete();
        List<Google_Calendar_Platform_Event__e> platformEvents = this.createPlatformEvents(eventList, EventOperationType.DELETE_TYPE);

        this.publishPlatformEvents(platformEvents);
    }

    private void publishPlatformEvents(List<Google_Calendar_Platform_Event__e> platformEvents) {
        if (!platformEvents.isEmpty()) EventBus.publish(platformEvents);

        System.debug('PLATFORM EVENTS SIZE= ' + platformEvents.size() + ' Platform events: ' + platformEvents);
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////

    private List<Google_Calendar_Platform_Event__e> createPlatformEvents(List<Event> eventList, String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();

        if (!eventList.isEmpty()) {
            for (Event event : eventList) {
                platformEvents.add(
                        new Google_Calendar_Platform_Event__e(
                                Salesforce_Event_JSON__c = JSON.serialize(event),
                                // Google_Event_Id__c = event.Google_Event_Id__c,
                                Operation_Type__c = operationType
                        )
                );
            }
        }
        return platformEvents;
    }

    private List<Event> eventsForInsert() {
        return (List<Event>) Trigger.new;
    }

    private List<Event> eventsForUpdate() {
        Map<Id, Event> oldEventsMap = (Map<Id, Event>) Trigger.oldMap;
        List<Event> eventList = new List<Event>();

        for (Event event : (List<Event>) Trigger.new) {
            Event oldEvent = oldEventsMap.get(event.Id);

            // create platform event if one of the fields has been changed
            if (this.isEventChanged(event, oldEvent)) {
                eventList.add(event);
            }
        }

        return eventList;
    }

    private List<Event> eventsForDelete() {
        List<Event> eventList = new List<Event>();

        for (Event event : (List<Event>) Trigger.old) {
            if (event.Google_Event_Id__c == null) continue; // The deleted event is not present in the google calendar

            eventList.add(event);
        }

        return eventList;
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

///////////////////// EXCEPTION ////////////////////////////////////////////////////////////////////////////////////
    public class EventTriggerHandlerException extends Exception {
    }
}