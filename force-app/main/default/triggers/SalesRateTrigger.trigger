trigger SalesRateTrigger on Sales_Rate__c (before insert, before update) {
    SalesRateTriggerHandler.checkCosts(trigger.new);
}