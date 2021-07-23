/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

public with sharing class TestDataFactory {
    private static final String ADMIN_PROFILE_NAME = 'System Administrator';
    public static final String USERNAME = 'adminusertest1@test.com';

    public static User createAdminUser() {
        Profile adminProfile = [
                SELECT
                        Id
                FROM Profile
                WHERE Name = :ADMIN_PROFILE_NAME
                LIMIT 1
        ];

        User adminUser = new User(
                Alias = 'admin',
                Email = USERNAME,
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                FirstName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = adminProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = USERNAME
        );
        insert adminUser;

        return adminUser;
    }

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

    public static List<Google_Calendar_Platform_Event__e> createPlatformEvents(Integer count, String operationType) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();
        List<Event> eventList = createEvents(count);

        for (Event event : eventList) {
            platformEvents.add(
                    new Google_Calendar_Platform_Event__e(
                            Salesforce_Event_JSON__c = JSON.serialize(event),
                            Operation_Type__c = operationType
                    )
            );
        }

        return platformEvents;
    }

    public static List<Google_Calendar_Platform_Event__e> createPlatformEvents(Integer count, String operationType, List<Event> events) {
        List<Google_Calendar_Platform_Event__e> platformEvents = new List<Google_Calendar_Platform_Event__e>();

        for (Event event : events) {
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