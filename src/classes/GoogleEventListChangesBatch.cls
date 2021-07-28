/**
 * Created by Vladyslav Kravchuk on 7/26/2021.
 */

public with sharing class GoogleEventListChangesBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
//    public Database.queryLocator start(Database.BatchableContext batchableContext) {
//        return Database.getQueryLocator('SELECT Id FROM Account Limit 1'); // skip start method
//    }
//
//    public void execute(Database.BatchableContext batchableContext, List<SObject> param) {
//        CalendarApi calendarApi = new CalendarApi(this.getCalendarId());
//        HttpResponse response = calendarApi.getEventListChanges();
//        List<GoogleEventListStructure.ListItem> googleEventList = GoogleEventListStructure.deserializeEventsToList(response.getBody());
//
//        if (googleEventList.isEmpty()) return ;
//
//
//        this.insertEvents(this.getGoogleEventsByStatus(googleEventList, GoogleEventListStructure.EVENT_STATUS_CONFIRMED)); // only inserts New events from Google calendar in salesforce
//        this.deleteEvents(this.getGoogleEventsByStatus(googleEventList, GoogleEventListStructure.EVENT_STATUS_CANCELED)); // only inserts New events from Google calendar in salesforce
//    }
//
//    public void finish(Database.BatchableContext batchableContext) {
//    }
//
//    private void insertEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
//        if (googleEventList.isEmpty()) return;
//
//        List<Event> salesforceEventsToInsert = new List<Event>();
//
//        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
//            salesforceEventsToInsert.add(new Event(
//                    Google_Event_Id__c = googleEvent.Id,
//                    Subject = googleEvent.summary,
//                    Description = googleEvent.description,
//                    StartDateTime = (Datetime) JSON.deserialize('"' + googleEvent.start.dateTimes + '"', Datetime.class), // String to DateTime
//                    EndDateTime = (Datetime) JSON.deserialize('"' + googleEvent.ends.dateTimes + '"', Datetime.class) // String to DateTime
//            ));
//        }
//
//        try {
//            Database.upsert(salesforceEventsToInsert, Event.Google_Event_Id__c, false);
//        } catch (Exception e) {
//            System.debug(e.getMessage());
//        }
//    }
//
//    private void deleteEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
//        if (googleEventList.isEmpty()) return;
//
//        List<String> googleEventIds = this.getGoogleEventIds(googleEventList);
//        List<Event> salesforceEventsToDelete = [SELECT Id,Google_Event_Id__c FROM Event WHERE Google_Event_Id__c IN:googleEventIds];
//
//        try {
//            Database.delete(salesforceEventsToDelete, false);
//        } catch (Exception e) {
//            System.debug(e.getMessage());
//        }
//
//    }
//
//    private List<GoogleEventListStructure.ListItem> getGoogleEventsByStatus(List<GoogleEventListStructure.ListItem> googleEventList, String eventStatus) {
//        List<GoogleEventListStructure.ListItem> result = new List<GoogleEventListStructure.ListItem>();
//
//        if (googleEventList.isEmpty()) return result;
//
//        for (GoogleEventListStructure.ListItem gEvent : googleEventList) {
//            if (gEvent.status == eventStatus) result.add(gEvent);
//        }
//
//        return result;
//    }
//
//    private String getCalendarId() {
//        return new CalendarApi().getOwnerCalendarId();
//    }
//
//    private List<String> getGoogleEventIds(List<GoogleEventListStructure.ListItem> googleEventList) {
//        List<String> eventIds = new List<String>();
//
//        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
//            eventIds.add(googleEvent.Id);
//        }
//
//        return eventIds;
//    }

    public void execute(Database.BatchableContext param1, List<SObject> param2) {
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return null;
    }
}