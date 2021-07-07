/**
 * Created by Vladyslav Kravchuk on 7/6/2021.
 */

@IsTest
private class GoogleCalPlatformEventTriggerHandlerTest {
    @TestSetup
    static void setup() {
        TestDataFactory.createAdminUser();
    }

    @IsTest
    static void afterInsertChunkTest() {
        Integer totalPlatformEventCount = 101;
        Integer allowedEventCountInChunk = GoogleCalPlatformEventTriggerHandler.calloutChunkSize;
        Integer expectedChunkGroupSize = getChunkGroupSize(allowedEventCountInChunk, totalPlatformEventCount);

        User adminUser = [SELECT Id FROM User WHERE Username = :TestDataFactory.USERNAME LIMIT 1];

        System.runAs(adminUser) {
            List<Google_Calendar_Platform_Event__e> platformEvents = TestDataFactory.createPlatformEvents(totalPlatformEventCount, EventOperationType.INSERT_TYPE);

            Test.startTest();
            List<Database.SaveResult> sr = EventBus.publish(platformEvents);
            Test.getEventBus().deliver();

            Test.stopTest();

            System.assertEquals(true, areAllEventsPublishedSuccessful(sr));
            System.assertEquals(expectedChunkGroupSize, GoogleCalPlatformEventTriggerHandler.chunkedPlatformEventsList.size(), 'Chunks should be equal');
            System.debug(GoogleCalPlatformEventTriggerHandler.chunkedPlatformEventsList);
        }
    }

    private static Integer getChunkGroupSize(Integer allowedEventCount, Integer customEventCount) {
        Decimal iterationGroup = (Decimal) customEventCount / allowedEventCount;

        if (iterationGroup < 1) {
            iterationGroup = 1;
        } else {
            iterationGroup = iterationGroup.round(System.RoundingMode.UP);
        }

        return (Integer) iterationGroup;
    }

    private static Boolean areAllEventsPublishedSuccessful(List<Database.SaveResult> publishResults) {
        for (Database.SaveResult sr : publishResults) {
            if (!sr.isSuccess()) return false;
        }
        return true;
    }
}