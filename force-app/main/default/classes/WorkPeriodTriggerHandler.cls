public with sharing class WorkPeriodTriggerHandler {
    public static void checkDates(List<Work_Period__c> workPeriodslist) {
        for (Work_Period__c workPeriodItem : workPeriodslist) {
            if (workPeriodItem.Start_Date__c > workPeriodItem.End_Date__c) {
                workPeriodItem.addError('End date can\'t be before start date');
            } else if (workPeriodItem.Start_Date__c == null) {
                workPeriodItem.addError('No start date!');
            } else if (workPeriodItem.End_Date__c == null) {
                workPeriodItem.addError('No end date!');
            }
        }
    }
}
