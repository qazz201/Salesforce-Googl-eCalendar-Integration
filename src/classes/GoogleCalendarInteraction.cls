/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

public with sharing class GoogleCalendarInteraction {

    public static void insertEvent(Event event) {
        executeCallout(JSON.serialize(event));
    }

    public static void updateEvent(Event event) {
        executeCallout(JSON.serialize(event));
    }

    public static void deleteEvent(Event event) {
        executeCallout(JSON.serialize(event));
    }

    @Future(callout=true)
    public static void executeCallout(String event) {
        EventFromJSON ev = (EventFromJSON) JSON.deserialize(event, EventFromJSON.class);

        HttpResponse resp = new CalendarApi('201qazz@gmail.com').insertEvent('{' +
                '"summary":"' + ev.Subject + '",' +
                ' "start": {' +
                '    "dateTime":"' + ev.StartDateTime + '"' +
                '  },' +
                '  "end": {' +
                '    "dateTime":"' + ev.EndDateTime + '"' +
                '  }' +
                '}');
        System.debug('GOOOOOOOOOOOGLE' + resp.getBody());

        if (resp.getStatusCode() == 200) {
            GoogleResponse googleParseResp = (GoogleResponse) JSON.deserialize(resp.getBody(), GoogleResponse.class);
            System.debug('200000000000 ID=' + googleParseResp.Id);
            createSalesforceGoogleEventAssociation(ev.Id, googleParseResp.Id);
        }
    }

    private static void createSalesforceGoogleEventAssociation(String salesforceEventId, String googleEventId) {
        insert new Google_Calendar_Event__c(
                Salesforce_Event_Id__c = salesforceEventId,
                Google_Event_Id__c = googleEventId
        );
    }

    public class EventFromJSON {
        public String Id;
        public String Subject;
        public String StartDateTime;
        public String EndDateTime;
    }

    public class GoogleResponse {
        public String Id;
    }
}