public with sharing class RevenueReportController {
    @AuraEnabled
    public static String getOrders() {
        List<Order__c> orderList =  [SELECT Name, 
                                    Account__r.Name, 
                                    (SELECT Name, Sales_Price__c, Cost_Price__c FROM Sales_Rates__r), 
                                    (SELECT Name, Start_Date__c, End_Date__c, Sales_Rate__c FROM Work_Periods__r ORDER BY Start_Date__c ASC) 
                                    FROM Order__c];
        Set<String> accounts = new Set<String>();
        Map<String, List<Order__c>> groupedOrdersMap = new Map<String, List<Order__c>>();
        
        for (Order__c orderItem : orderList) {
            accounts.add(orderItem.Account__r.Name);
        }
        for (String accountItem : accounts) {
            List<Order__c> orders = new List<Order__c>();
            for (Order__c orderItem : orderList) {
                if (orderItem.Account__r.Name == accountItem) orders.add(orderItem);
            }
            groupedOrdersMap.put(accountItem, orders);
        }

        return JSON.serialize(CalculateRevenue.getWeeklyRevenue(groupedOrdersMap));
    }
}
