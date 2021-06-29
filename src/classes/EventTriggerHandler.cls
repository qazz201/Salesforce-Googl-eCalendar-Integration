/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class EventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        this.publishPlatformEvent(PlatformEventTypes.INSERT_TYPE);
    }

    public override void afterUpdate() {
        this.publishPlatformEvent(PlatformEventTypes.UPDATE_TYPE);
    }

    public override void afterDelete() {
        //   this.publishPlatformEvent(PlatformEventTypes.DELETE_TYPE);
    }

    private void publishPlatformEvent(String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();
        Map<Id, Event> oldEventsMap = (Map<Id, Event>) Trigger.oldMap;

        for (Event event : (List<Event>) Trigger.new) {
            Boolean runOperation = runOperation(event, oldEventsMap);
            System.debug('RUN OPERATION ' + operationType + ' ' + runOperation);

            // TODO: Change this logic
            if (runOperation) {
                platformEvents.add(new Google_Calendar_Platform_Event__e(
                        Salesforce_Event_Id__c = event.Id,
                        Google_Event_Id__c = event.Google_Event_Id__c,
                        Operation_Type__c = operationType)
                );
            }
        }

        System.debug('PLATFORM EVENTS SIZE= ' + platformEvents.size() + ' EMPTY? ' + platformEvents.isEmpty());
        if (!platformEvents.isEmpty())EventBus.publish(platformEvents);
    }

    // TODO: Change this logic ( run trigger logic if one of the fields is updated, else no trigger run )
    private Boolean runOperation(Event newEvent, Map<Id, Event> oldEventsMap) {
        if (oldEventsMap == null) return true; // Creation of new record

        Event oldEvent = oldEventsMap.get(newEvent.Id);

        if (newEvent.Subject != oldEvent.Subject
                || newEvent.Description != oldEvent.Description
                || newEvent.StartDateTime != oldEvent.StartDateTime
                || newEvent.EndDateTime != oldEvent.EndDateTime) {
            return true;
        }

        return false;
    }

///////////////////// EXCEPTION ////////////////////////////////////////////////////////////////////////////////////
    public class EventTriggerHandlerException extends Exception {
    }
}