/**
 * Created by Vladyslav Kravchuk on 7/28/2021.
 */

public with sharing class GoogleEventsChangesScheduler implements Schedulable {

    // System.schedule('GoogleEventsChangesScheduler', '0 0 0,4,8,12,16,20 * * ?', new GoogleEventsChangesScheduler()) - every 4 hours
    public void execute(SchedulableContext context) {
        syncEventsFromGoogle();
    }

    @Future(callout=true)
    public static void syncEventsFromGoogle() {
        HttpResponse response = new CalendarApi().getEventListChanges();
        List<GoogleEventListStructure.ListItem> googleEventList = GoogleEventListStructure.deserializeEventsToList(response.getBody());

        if (googleEventList.isEmpty()) return ;

        upsertEvents(getGoogleEventsByStatus(googleEventList, GoogleEventListStructure.EVENT_STATUS_CONFIRMED)); // only inserts New events from Google calendar in salesforce
        deleteEvents(getGoogleEventsByStatus(googleEventList, GoogleEventListStructure.EVENT_STATUS_CANCELED)); // only inserts New events from Google calendar in salesforce
    }

    private static void upsertEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
        if (googleEventList.isEmpty()) return;

        List<Event> salesforceEventsToInsert = new List<Event>();

        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
            salesforceEventsToInsert.add(new Event(
                    Google_Event_Id__c = googleEvent.Id,
                    Subject = googleEvent.summary,
                    Description = googleEvent.description,
                    StartDateTime = (Datetime) JSON.deserialize('"' + googleEvent.start.dateTimes + '"', Datetime.class), // String to DateTime
                    EndDateTime = (Datetime) JSON.deserialize('"' + googleEvent.ends.dateTimes + '"', Datetime.class) // String to DateTime
            ));
        }

        try {
            Database.upsert(salesforceEventsToInsert, Event.Google_Event_Id__c, false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static void deleteEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
        if (googleEventList.isEmpty()) return;

        List<String> googleEventIds = getGoogleEventIds(googleEventList);
        List<Event> salesforceEventsToDelete = [SELECT Id,Google_Event_Id__c FROM Event WHERE Google_Event_Id__c IN:googleEventIds];

        try {
            Database.delete(salesforceEventsToDelete, false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static List<GoogleEventListStructure.ListItem> getGoogleEventsByStatus(List<GoogleEventListStructure.ListItem> googleEventList, String eventStatus) {
        List<GoogleEventListStructure.ListItem> result = new List<GoogleEventListStructure.ListItem>();

        if (googleEventList.isEmpty()) return result;

        for (GoogleEventListStructure.ListItem gEvent : googleEventList) {
            if (gEvent.status == eventStatus) result.add(gEvent);
        }

        return result;
    }

    private static List<String> getGoogleEventIds(List<GoogleEventListStructure.ListItem> googleEventList) {
        List<String> eventIds = new List<String>();

        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
            eventIds.add(googleEvent.Id);
        }

        return eventIds;
    }
}