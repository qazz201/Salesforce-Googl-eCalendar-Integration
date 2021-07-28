/**
 * Created by Vladyslav Kravchuk on 7/28/2021.
 */

@IsTest
private class GoogleEventsBatchSchedulerTest {
    private static final String JOB_NAME = 'Batch Scheduler';

    @IsTest
    static void scheduleTest() {
        Test.startTest();
        System.schedule(JOB_NAME, '0 0 3 ? * *', new GoogleEventsBatchScheduler());
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [
                SELECT
                        Id
                        , ApexClassID
                        , ApexClass.Name
                        , Status
                        , JobType
                FROM AsyncApexJob
                WHERE JobType = 'ScheduledApex'
        ];

        System.assertEquals(false, jobsScheduled.isEmpty(), 'Expecting one scheduled job');
        System.assert(GoogleEventsBatchScheduler.class.getName().contains(jobsScheduled[0].ApexClass.Name));

        List<AsyncApexJob> jobsApexBatch = [
                SELECT
                        Id
                        , ApexClassID
                        , ApexClass.Name
                        , Status
                        , JobType
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
        ];

        System.assertEquals(false, jobsApexBatch.isEmpty(), 'Expecting one apex batch job');
        System.assert(GoogleEventListChangesBatch.class.getName().contains(jobsApexBatch[0].ApexClass.Name));
    }
}