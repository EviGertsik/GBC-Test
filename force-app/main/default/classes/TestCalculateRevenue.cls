@isTest
public with sharing class TestCalculateRevenue {

    @isTest
    public static void testGetOrders() {

        //inserting test data for positive testing

        TestDataFactory.insertOrdersPositive();

        //getting grouped orders map from controller to get the count of processed accounts

        Map<String, List<Order__c>> groupedOrdersMap = RevenueReportController.groupOrdersByAccount(RevenueReportController.queryOrders());

        //querying accounts count with orders to assert it with the accounts count in map

        Integer accountsCount = (Integer) [Select COUNT_DISTINCT(Account__c) FROM Order__c][0].get('expr0');

        //checking if all accounts with orders are grouped

        System.assert(accountsCount == groupedOrdersMap.keyset().size());

        Map<String, Object> testMap = (Map<String, Object>) JSON.deserializeUntyped(RevenueReportController.getWeeklyRevenueReport());
        List<Object> totalsList = (List<Object>) testMap.get('TOTAL');

        //getting total revenue & wrapper

        Map<String,Object> totalsMap = (Map<String,Object>) totalsList[0];

        //asserting expected total revenue & margin with actual

        System.assert(totalsMap.get('revenue') == 8900);
        System.assert(totalsMap.get('margin') == 2575);
    }

    @isTest
    public static void testNegativeSalesRateInsertion() {
        /*
            checking if invalid sales rates are not inserted
            they are considered invalid, if their cost price is higher than sales price
        */
        Database.SaveResult[] results = TestDataFactory.insertSalesRateNegative();
        Integer errorsCount = 0;
        for (Database.SaveResult result : results) {
            if(!result.isSuccess()) errorsCount++;
            System.assert(!result.isSuccess());
            List<Database.Error> errors = result.getErrors();
            //checking error message (should be from trigger)
            System.assert(errors[0].getMessage() == 'Cost price can\'t be larger than sales price!');
        }
        /*we have 2 sales rates with cost price higher than sales price,
        1 sales rate with cost price equal to sales price(should be good)*/
        System.assert(errorsCount == 2);
    }

    @isTest
    public static void testNegativeWorkPeriodsInsertion() {
        Database.SaveResult[] results = TestDataFactory.insertWorkPeriodsNegative();
        Integer errorsCount = 0;
        /*
            as I put work periods in a specific order,
            I can check assert certain errors with certain error messages,
            just by getting Database.error by index
        */
        for (Integer i = 0; i < results.size(); i++) {
            if(!results[i].isSuccess()) errorsCount++;
            System.debug(results[i].getErrors());
            List<Database.Error> errors = results[i].getErrors();
            switch on i {
                when 0, 2 {
                    System.assert(errors[0].getMessage() == 'No start date!');
                }
                when 1 {
                    System.assert(errors[0].getMessage() == 'No end date!');
                }
                when 3 {
                    System.assert(errors[0].getMessage() == 'End date can\'t be before start date');
                }
            }
        }
        /*we have 4 invalid work_periods__c records,
        so the error count should be 4*/
        System.assert(errorsCount == 4);
    }
}
