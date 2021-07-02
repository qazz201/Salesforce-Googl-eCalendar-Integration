/**
 * Created by Vladyslav Kravchuk on 6/26/2021.
 */

public with sharing class GoogleCalendarEventBodyGenerator {
    private String subject;
    private Datetime startDateTime;
    private Datetime endDateTime;
    private String description;

    // System reserved words
    private static final String reservedDateTime = 'dateTime';
    private static final String reservedEnd = 'end';

    public GoogleCalendarEventBodyGenerator(String subject, Datetime startDateTime, Datetime endDateTime, String description) {
        this.subject = subject;
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.description = description;
    }

    public String toJSON() {

        DateTimeFormatting start = new DateTimeFormatting(this.startDateTime);
        DateTimeFormatting finish = new DateTimeFormatting(this.endDateTime);
        BodyParser parser = new BodyParser(subject, description, start, finish);

        String result = JSON.serialize(parser).replace('ends', reservedEnd).replaceAll('dateTimes', reservedDateTime);

        return result;
    }

    public class BodyParser {
        public String summary;
        public String description;
        public DateTimeFormatting start;
        public DateTimeFormatting ends;

        public BodyParser(String summary, String description, DateTimeFormatting start, DateTimeFormatting ends) {
            this.summary = summary;
            this.description = description;
            this.start = start;
            this.ends = ends;
        }
    }

    public class DateTimeFormatting {
        public Datetime dateTimes;

        public DateTimeFormatting(Datetime dateTimes) {
            this.dateTimes = dateTimes;
        }
    }
}