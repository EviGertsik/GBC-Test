trigger WorkPeriodTrigger on Work_Period__c (before insert, before update) {
    if (trigger.isInsert) {
        WorkPeriodTriggerHandler.checkDates(trigger.new);
    }
}