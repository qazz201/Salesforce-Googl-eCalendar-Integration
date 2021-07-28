/**
 * Created by Vladyslav Kravchuk on 7/28/2021.
 */

public with sharing class GoogleEventsBatchScheduler implements Schedulable {

    // System.schedule('GoogleEventsBatchScheduler', '0 0 0,4,8,12,16,20 * * ?', new GoogleEventsBatchScheduler()) - every 4 hours
    public void execute(SchedulableContext context) {
        Database.executeBatch(new GoogleEventListChangesBatch());
    }
}