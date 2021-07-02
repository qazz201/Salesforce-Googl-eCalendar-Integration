/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public with sharing class GoogleCalPlatformEventTriggerHandler extends TriggerHandler {
    private static final Integer calloutChunkSize = 100; // 150-max

    //Limits.getHeapSize() >= Limits.getLimitHeapSize()
    public override void afterInsert() {
        List<EventOperation> eventOperations = new List<EventOperation>();
        List<Google_Calendar_Platform_Event__e> chunkedPlatformEvents = this.getChunkedPlatformEvents();

        Google_Calendar_Platform_Event__e lastPlatformEventInChunk = chunkedPlatformEvents[chunkedPlatformEvents.size() - 1];
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastPlatformEventInChunk.replayId);

        for (Google_Calendar_Platform_Event__e ple : chunkedPlatformEvents) {
            String event = ple.Salesforce_Event_JSON__c;
            String operationType = ple.Operation_Type__c;
            String googleEventId = ple.Google_Event_Id__c;

            eventOperations.add(new EventOperation(event, operationType, googleEventId));
        }

        System.enqueueJob(new GoogleCalendarCalloutQueue(eventOperations));
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    private List<Google_Calendar_Platform_Event__e> getChunkedPlatformEvents() {
        List<Google_Calendar_Platform_Event__e> chunkedPlatformEvents = new List<Google_Calendar_Platform_Event__e>();
        Integer counter = 0;

        for (Google_Calendar_Platform_Event__e ple : (List<Google_Calendar_Platform_Event__e>) Trigger.new) {
            if (counter > calloutChunkSize) break;
            chunkedPlatformEvents.add(ple);
            counter++;
        }

        return chunkedPlatformEvents;
    }

    public class EventOperation {
        public String eventJSON;
        public String operationType;
        public String googleEventId;

        public EventOperation(String eventJSON, String operationType, String googleEventId) {
            this.eventJSON = eventJSON;
            this.operationType = operationType;
            this.googleEventId = googleEventId;
        }
    }

    public class GoogleCalPlatformEventTriggerHandlerException extends Exception {
    }
}