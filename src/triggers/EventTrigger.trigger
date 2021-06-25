/**
 * Created by Vladyslav Kravchuk on 6/25/2021.
 */

trigger EventTrigger on Event (after insert, after update, after delete) {
    new EventTriggerHandler().execute();
}