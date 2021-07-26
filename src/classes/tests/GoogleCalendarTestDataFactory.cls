/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

public with sharing class GoogleCalendarTestDataFactory {

    public static List<Event> createEvents(Integer count) {
        List<Event> events = new List<Event>();

        for (Integer i = 0; i < count; i++) {
            Datetime dt = DateTime.now().addMinutes(i * 5);
            events.add(new Event(
                    Subject = 'Subject_' + i,
                    Description = 'Description_' + i,
                    StartDateTime = dt,
                    EndDateTime = dt.addMinutes(3)
            ));
        }

        return events;
    }

    public static List<Google_Calendar_Platform_Event__e> createPlatformEvents(Integer count, String operationType, List<Event> events) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();
        List<Event> iterationEvent = events;

        if (events == null) {
            iterationEvent = createEvents(count);
        }

        for (Event event : iterationEvent) {
            platformEvents.add(
                    new Google_Calendar_Platform_Event__e(
                            Salesforce_Event_JSON__c = JSON.serialize(event),
                            Operation_Type__c = operationType
                    )
            );
        }

        return platformEvents;
    }
}