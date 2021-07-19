/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

@IsTest
private class EventTriggerHandlerTest {
    @TestSetup
    static void setup() {
        System.runAs(TestDataFactory.createAdminUser()) {
            insert TestDataFactory.createEvents(5);
        }
    }

    @IsTest
    static void afterInsertTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TestDataFactory.USERNAME LIMIT 1];

        System.runAs(adminUser) {
            insert TestDataFactory.createEvents(1);

            System.assertEquals(false, EventTriggerHandler.pleEvents.isEmpty(), 'Platform events should be created');
        }
    }

    @IsTest
    static void afterUpdatePositiveTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TestDataFactory.USERNAME LIMIT 1];

        System.runAs(adminUser) {
            Event event = [SELECT Id,Subject FROM Event LIMIT 1];
            event.Subject = 'New subject';
            update event;

            System.assertEquals(false, EventTriggerHandler.pleEvents.isEmpty(), 'Platform events should be created');
        }
    }

    @IsTest
    static void afterUpdateNegativeTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TestDataFactory.USERNAME LIMIT 1];

        System.runAs(adminUser) {
            Event event = [SELECT Id,Location FROM Event LIMIT 1];
            event.Location = 'New location';
            update event;

            System.assertEquals(true, EventTriggerHandler.pleEvents.isEmpty(), 'No platform events should be created');
        }
    }

    @IsTest
    static void afterDeleteTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TestDataFactory.USERNAME LIMIT 1];

        System.runAs(adminUser) {
            List<Event> events = [SELECT Id,Location FROM Event];
            delete events;

            System.assertEquals(true, EventTriggerHandler.pleEvents.isEmpty(), 'No platform events should be created');
        }
    }

//    public class MockService implements HttpCalloutMock {
//
//        public HttpResponse respond(HttpRequest req) {
//            HttpResponse res = new HttpResponse();
//            res.setBody('{"items":[{"id":"calendarId","accessRole":"owner"}]}');
//            res.setStatusCode(200);
//            return res;
//        }
//    }
}