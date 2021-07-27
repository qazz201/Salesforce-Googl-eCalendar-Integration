/**
 * Created by Vladyslav Kravchuk on 7/27/2021.
 */

public with sharing class GoogleEventListStructure {
    public static final String EVENT_STATUS_CANCELED = 'cancelled';
    public static final String EVENT_STATUS_CONFIRMED = 'confirmed';

    public static List<ListItem> deserializeEventsToList(String eventBody) {
        String updatedBody = eventBody.replaceAll('end', 'ends').replaceAll('dateTime', 'dateTimes'); // 'end','dateTime' -reserved words
        EventList events = (EventList) JSON.deserialize(updatedBody, EventList.class);

        return new List<ListItem>(events.items);
    }

    public class EventList {
        public List<ListItem> items;
    }

    public class ListItem {
        public String Id;
        public String summary;
        public String created;
        public String description;
        public String status; // cancelled, confirmed
        public StartEndDateTime start;
        public StartEndDateTime ends;
    }

    public class StartEndDateTime {
        public String dateTimes;
    }
}