public with sharing class RevenueReportController {

    @AuraEnabled
    public static String getWeeklyRevenueReport() {
        return JSON.serialize(CalculateRevenue.getWeeklyRevenue(groupOrdersByAccount(queryOrders())));
    }

    public static List<Order__c> queryOrders() {
        return [SELECT Name,
                Account__r.Name,
                (SELECT Name, Sales_Price__c, Cost_Price__c FROM Sales_Rates__r),
                (SELECT Name, Start_Date__c, End_Date__c, Sales_Rate__c
                FROM Work_Periods__r ORDER BY Start_Date__c ASC)
                FROM Order__c];
    }

    public static Map<String, List<Order__c>> groupOrdersByAccount(List<Order__c> orderList) {
        Map<String, List<Order__c>> groupedOrdersMap = new Map<String, List<Order__c>>();
        Set<String> accountsSet = new Set<String>();

        //collect set of account names

        for (Order__c orderItem : orderList) {
            accountsSet.add(orderItem.Account__r.Name);
        }

        //group orders for each account

        for (String accountItem : accountsSet) {
            List<Order__c> orders = new List<Order__c>();
            for (Order__c orderItem : orderList) {
                if (orderItem.Account__r.Name == accountItem) orders.add(orderItem);
            }
            groupedOrdersMap.put(accountItem, orders);
        }
        return groupedOrdersMap;
    }
}
