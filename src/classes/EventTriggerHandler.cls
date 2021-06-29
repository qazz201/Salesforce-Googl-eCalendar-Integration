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

        for (Event event : (List<Event>) Trigger.new) {
            platformEvents.add(new Google_Calendar_Platform_Event__e(
                    Salesforce_Event_Id__c = event.Id,
                    Operation_Type__c = operationType)
            );
        }

        EventBus.publish(platformEvents);
    }

    ///////////////////// EXCEPTION ////////////////////////////////////////////////////////////////////////////////////
    public class EventTriggerHandlerException extends Exception {
    }
}