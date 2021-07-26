/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

@IsTest
private class EventTriggerHandlerTest {
    @TestSetup
    static void setup() {
        insert GoogleCalendarTestDataFactory.createEvents(5);
    }

    @IsTest
    static void afterInsertTest() {
        insert GoogleCalendarTestDataFactory.createEvents(1);

        System.assertEquals(false, EventTriggerHandler.pleEvents.isEmpty(), 'Platform events should be created');

    }

    @IsTest
    static void afterUpdatePositiveTest() {
        Event event = [SELECT Id,Subject FROM Event LIMIT 1];
        event.Subject = 'New subject';
        update event;

        System.assertEquals(false, EventTriggerHandler.pleEvents.isEmpty(), 'Platform events should be created');

    }

    @IsTest
    static void afterUpdateNegativeTest() {
        Event event = [SELECT Id,Location FROM Event LIMIT 1];
        event.Location = 'New location';
        update event;

        System.assertEquals(true, EventTriggerHandler.pleEvents.isEmpty(), 'No platform events should be created');
    }

    @IsTest
    static void afterDeleteTest() {
        List<Event> events = [SELECT Id,Location FROM Event];
        delete events;

        System.assertEquals(true, EventTriggerHandler.pleEvents.isEmpty(), 'No platform events should be created');
    }
}