public with sharing class SalesRateTriggerHandler {
    public static void checkCosts(List<Sales_Rate__c> salesRatesList) {
        for (Sales_Rate__c sr : salesRatesList) {
            if (sr.Cost_Price__c > sr.Sales_Price__c) {
                sr.addError('Cost price can\'t be larger than sales price!');
            }
        }
    }
}
