trigger WorkPeriodTrigger on Work_Period__c (before insert, before update) {
    WorkPeriodTriggerHandler.checkDates(trigger.new);
}
