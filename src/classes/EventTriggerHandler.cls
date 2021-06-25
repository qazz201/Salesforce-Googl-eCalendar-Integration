/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class EventTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        Google_Platform_Event_Type__mdt platformEventTypes = getGooglePlatformEventTypes();
        this.publishPlatformEvent(platformEventTypes.Event_Insert__c);
    }

    public override void afterUpdate() {
        Google_Platform_Event_Type__mdt platformEventTypes = getGooglePlatformEventTypes();
        this.publishPlatformEvent(platformEventTypes.Event_Update__c);
    }

    public override void afterDelete() {
        Google_Platform_Event_Type__mdt platformEventTypes = getGooglePlatformEventTypes();
        this.publishPlatformEvent(platformEventTypes.Event_Delete__c);
    }


    private void publishPlatformEvent(String eventType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();

        for (Event event : (List<Event>) Trigger.new) {
            platformEvents.add(new Google_Calendar_Platform_Event__e(
                    Salesforce_Event_Id__c = event.Id,
                    Event_Type__c = eventType));
        }

        EventBus.publish(platformEvents);
    }

    ///////////////////// UTILITY //////////////////////////////////////////////////////////////////////////////////////
    private Google_Platform_Event_Type__mdt getGooglePlatformEventTypes() {
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
}