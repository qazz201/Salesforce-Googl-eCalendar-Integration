/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public with sharing class GoogleCalPlatformEventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        Google_Platform_Event_Type__mdt platformEventTypes = this.getGooglePlatformEventTypes();
        Map<Id, Event> salesforceEvents = this.getSalesforceEvents();

        if (platformEventTypes != null) {
            for (Google_Calendar_Platform_Event__e ple : (List <Google_Calendar_Platform_Event__e>) Trigger.new) {

                String eventType = ple.Event_Type__c;
                Event event = salesforceEvents.get(ple.Salesforce_Event_Id__c);

                if (eventType == platformEventTypes.Event_Insert__c) {
                    GoogleCalendarInteraction.insertEvent(event);

                } else if (eventType == platformEventTypes.Event_Update__c) {
                    GoogleCalendarInteraction.updateEvent(event);

                } else if (eventType == platformEventTypes.Event_Delete__c) {
                    GoogleCalendarInteraction.deleteEvent(event);

                } else {
                    String errorMsg = 'ERROR: Choose appropriate platform event type: INSERT,UPDATE,DELETE. Current is' + ple.Event_Type__c;
                    System.debug(errorMsg);
                    throw new GoogleCalPlatformEventTriggerHandlerException(errorMsg);
                }
            }
        }
    }

    /////////////////////// UTILITY ////////////////////////////////////////////////////////////////////////////////////
    /**
     *  Get salesforce events from platform event
     * @return
     */
    private Map<Id, Event> getSalesforceEvents() {
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

    public class GoogleCalPlatformEventTriggerHandlerException extends Exception {
    }
}