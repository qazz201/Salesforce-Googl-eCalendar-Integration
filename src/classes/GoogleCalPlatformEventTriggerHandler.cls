/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public with sharing class GoogleCalPlatformEventTriggerHandler extends TriggerHandler {
    private static final Integer calloutChunkSize = 100; // 150-max

    //Limits.getHeapSize() >= Limits.getLimitHeapSize()
    public override void afterInsert() {
        List<EventOperation> eventOperations = new List<EventOperation>();
        List<Google_Calendar_Platform_Event__e> chunkedPlatformEvents = this.getChunkedPlatformEvents();

        if (chunkedPlatformEvents.isEmpty()) return;

        Google_Calendar_Platform_Event__e lastPlatformEventInChunk = chunkedPlatformEvents[chunkedPlatformEvents.size() - 1];
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastPlatformEventInChunk.replayId);

        for (Google_Calendar_Platform_Event__e ple : chunkedPlatformEvents) {
            EventDeserialize event = this.deserializeEventWithCustomFields(ple.Salesforce_Event_JSON__c);
            String operationType = ple.Operation_Type__c;

            eventOperations.add(new EventOperation(event, operationType));
        }

        System.enqueueJob(new GoogleCalendarCalloutQueue(eventOperations));
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    private List<Google_Calendar_Platform_Event__e> getChunkedPlatformEvents() {
        List<Google_Calendar_Platform_Event__e> chunkedPlatformEvents = new List<Google_Calendar_Platform_Event__e>();
        Integer counter = 0;

        for (Google_Calendar_Platform_Event__e ple : (List<Google_Calendar_Platform_Event__e>) Trigger.new) {
            if (counter >= calloutChunkSize) break;
            chunkedPlatformEvents.add(ple);
            counter++;
        }

        return chunkedPlatformEvents;
    }

    private EventDeserialize deserializeEventWithCustomFields(String eventJSON) {
        return (EventDeserialize) JSON.deserialize(eventJSON.replaceAll('__c', ''), EventDeserialize.class);
    }

    public class EventOperation {
        public EventDeserialize event;
        public String operationType;
        // public String googleEventId;

        public EventOperation(EventDeserialize event, String operationType) {
            this.event = event;
            this.operationType = operationType;
            // this.googleEventId = googleEventId;
        }
    }
    public class EventDeserialize {
        public String Id;
        public String Subject;
        public Datetime StartDateTime;
        public Datetime EndDateTime;
        public String Description;
        public String Google_Event_Id;
    }

    public class GoogleCalPlatformEventTriggerHandlerException extends Exception {
    }
}