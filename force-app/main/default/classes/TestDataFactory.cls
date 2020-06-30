@isTest
public with sharing class TestDataFactory {
    public static void insertOrdersPositive() {
        /*
            inserting account & order separalely, because we'll need their IDs for later
        */
        Order__c order = createOrderPositive();
        /*
            now that we have the needed IDs we can proceed with inserting sales rates & work periods
        */
        List<Sales_Rate__c> salesRatesList = createSalesRatesPositive(order);
        createWorkPeriodsPositive(order);
    }

    //creating order because we'll need its ID later

    public static Order__c createOrderPositive() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Order__c order = new Order__c(Account__c = acc.Id);
        insert order;
        return order;
    }

    //creating sales rates for positive testing & for getting their IDs

    static List<Sales_Rate__c> createSalesRatesPositive(Order__c order) {
        Sales_Rate__c salesRate1 = new Sales_Rate__c(Order__c = order.Id, Name = 'Test Rate 1', Sales_Price__c = 300, Cost_Price__c = 225);
        Sales_Rate__c salesRate2 = new Sales_Rate__c(Order__c = order.Id, Name = 'Test Rate 2', Sales_Price__c = 400, Cost_Price__c = 275);
        List<Sales_Rate__c> salesRatesList = new List<Sales_Rate__c>{salesRate1, salesRate2};
        insert salesRatesList;
        return salesRatesList;
    }

    static void createWorkPeriodsPositive(Order__c order) {
        List<Sales_Rate__c> salesRatesList = createSalesRatesPositive(order);
        Work_Period__c workPeriod1 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[0].Id,
                                                        Start_Date__c = Date.newInstance(2015, 1, 13),
                                                        End_Date__c = Date.newInstance(2015, 1, 16));
        Work_Period__c workPeriod2 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[1].Id,
                                                        Start_Date__c = Date.newInstance(2015, 1, 24),
                                                        End_Date__c = Date.newInstance(2015, 2, 6));
        Work_Period__c workPeriod3 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[0].Id,
                                                        Start_Date__c = Date.newInstance(2015, 2, 14),
                                                        End_Date__c = Date.newInstance(2015, 2, 20));
        List<sObject> workPeriodsList = new List<sObject>{workPeriod1, workPeriod2, workPeriod3};
        insert workPeriodsList;
    }

    //testing sales rates trigger (cost price should not be higher than sales price)

    public static Database.SaveResult[] insertSalesRateNegative() {
        Order__c order = createOrderPositive();
        Sales_Rate__c salesRate1 = new Sales_Rate__c(Order__c = order.Id, Name = 'Test Rate 1', Sales_Price__c = 300, Cost_Price__c = 325);
        Sales_Rate__c salesRate2 = new Sales_Rate__c(Order__c = order.Id, Name = 'Test Rate 2', Sales_Price__c = 400, Cost_Price__c = 475);
        Sales_Rate__c salesRate3 = new Sales_Rate__c(Order__c = order.Id, Name = 'Test Rate 2', Sales_Price__c = 400, Cost_Price__c = 400);
        List<SObject> salesRatesList = new List<SObject>{salesRate1, salesRate2};
        return Database.insert(salesRatesList, false);
    }


    //  checking if start/end dates are missing & if end date is earlier than start date

    public static Database.SaveResult[] insertWorkPeriodsNegative() {
        Order__c order = createOrderPositive();
        List<Sales_Rate__c> salesRatesList = createSalesRatesPositive(order);
        //no start date
        Work_Period__c workPeriod1 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[0].id,
                                                        Start_Date__c = null,
                                                        End_Date__c = Date.newInstance(2015, 1, 16));
        //no end date
        Work_Period__c workPeriod2 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[1].id,
                                                        Start_Date__c = Date.newInstance(2015, 1, 24),
                                                        End_Date__c = null);
        //no dates
        Work_Period__c workPeriod3 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[0].id,
                                                        Start_Date__c = null,
                                                        End_Date__c = null);
        //end date is earlier than start date
        Work_Period__c workPeriod4 = new Work_Period__c(Order__c = order.Id,
                                                        Sales_Rate__c = salesRatesList[0].id,
                                                        Start_Date__c = Date.newInstance(2015, 1, 24),
                                                        End_Date__c = Date.newInstance(2015, 1, 16));
        return Database.insert(new List<Work_Period__c>{workPeriod1, workPeriod2, workPeriod3, workPeriod4}, false);
    }

}
