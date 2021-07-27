/**
 * Created by Vladyslav Kravchuk on 7/26/2021.
 */

public with sharing class GoogleEventListChangesBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Database.queryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator('SELECT Id FROM Account Limit 1'); // skip start method
    }

    public void execute(Database.BatchableContext batchableContext, List<SObject> param) {
        CalendarApi calendarApi = new CalendarApi(this.getCalendarId());
        HttpResponse response = calendarApi.getEventListChanges();
        List<GoogleEventListStructure.ListItem> googleEventList = GoogleEventListStructure.deserializeEventsToList(response.getBody());

        if (googleEventList.isEmpty()) return ;

        this.insertEvents(this.getGoogleNewlyCreatedEvents(googleEventList)); // only inserts New events from Google calendar in salesforce
    }

    public void finish(Database.BatchableContext batchableContext) {
    }

    private void insertEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
        if (googleEventList.isEmpty()) return;

        List<Event> salesforceEventsToInsert = new List<Event>();

        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
            salesforceEventsToInsert.add(new Event(
                    Google_Event_Id__c = googleEvent.Id,
                    Subject = googleEvent.summary,
                    Description = googleEvent.description,
                    StartDateTime = Datetime.valueOf(googleEvent.start.dateTimes.replace('T', ' ')), // String to DateTime
                    EndDateTime = Datetime.valueOf(googleEvent.ends.dateTimes.replace('T', ' ')) // String to DateTime
            ));
        }

        try {
            Database.insert(salesforceEventsToInsert, false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private List<GoogleEventListStructure.ListItem> getGoogleNewlyCreatedEvents(List<GoogleEventListStructure.ListItem> googleEventList) {
        List<String> googleEventIds = this.getGoogleEventIds(googleEventList);
        List<String> googleEventIdsToOmit = new List<String>(); // they already in Salesforce

        List<Event> salesforceEventsByGoogleIds = [SELECT Id,Google_Event_Id__c FROM Event WHERE Google_Event_Id__c IN:googleEventIds];
        List<GoogleEventListStructure.ListItem> result = new List<GoogleEventListStructure.ListItem>();

        for (Event event : salesforceEventsByGoogleIds) {
            googleEventIdsToOmit.add(event.Google_Event_Id__c);
        }

        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
            if (googleEventIdsToOmit.contains(googleEvent.Id) || googleEvent.status == GoogleEventListStructure.EVENT_STATUS_CANCELED) continue; // omit google event that already in salesforce or canceled

            result.add(googleEvent);
        }

        return result;
    }

    private String getCalendarId() {
        return new CalendarApi().getOwnerCalendarId();
    }

    private List<String> getGoogleEventIds(List<GoogleEventListStructure.ListItem> googleEventList) {
        List<String> eventIds = new List<String>();

        for (GoogleEventListStructure.ListItem googleEvent : googleEventList) {
            eventIds.add(googleEvent.Id);
        }

        return eventIds;
    }
}