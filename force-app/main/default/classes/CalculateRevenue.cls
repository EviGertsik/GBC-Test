public with sharing class CalculateRevenue {

    public static Map<String, List<RevenueWrapper>> getWeeklyRevenue(Map<String, List<Order__c>> groupedOrdersMap) {

        Map<String, List<RevenueWrapper>> groupedWeeklyRevenueMap = new Map<String, List<RevenueWrapper>>();

        //iterating through each account in the map

        for (String account: groupedOrdersMap.keySet()) {

            //making weekly revenue & margin list for each account

            List <RevenueWrapper> weeklyRevenuesList = new List <RevenueWrapper>();

            //iterating through each order of account

            for (Order__c orderItem: groupedOrdersMap.get(account)) {

            //iterating through each work period of account order

                for (Work_Period__c wp: orderItem.Work_Periods__r) {
                    Date firstWeekStart = wp.Start_Date__c.toStartofWeek();
                    Date lastWeekStart = wp.End_Date__c.toStartofWeek();

                    //tempDate is used for getting each week start date of work period

                    Date tempDate = firstWeekStart;
                    List <String> orderWeekBordersList = new List <String>();
                    Decimal revenue = 0;
                    Decimal margin = 0;

                    //looking if work period ends before end of the first week. Need this statement for different revenue/margin calculation

                    if (wp.End_Date__c <= (firstWeekStart.addDays(6))) {

                        //finding sales rate for the work period & calculating revenue, margin, period for wrapper

                        for (Sales_Rate__c sr: orderItem.Sales_Rates__r) {
                            if (sr.Id == wp.Sales_Rate__c) {

                                //here I increment days count by 1 because the last day counts too

                                revenue = sr.Sales_Price__c * (wp.Start_Date__c.daysBetween(wp.End_Date__c) + 1);
                                margin = revenue - sr.Cost_Price__c * (wp.Start_Date__c.daysBetween(wp.End_Date__c) + 1);
                                weeklyRevenuesList.add(new RevenueWrapper(revenue, margin, firstWeekStart.format() + ' - ' + firstWeekStart.addDays(6).format()));
                            }
                        }

                    } else {

                        //incrementing weeks count by 1 because partial week counts too

                        Integer weeksCount = firstWeekStart.daysBetween(lastWeekStart) / 7 + 1;

                        for (Integer i = 0; i < weeksCount; i++) {


                            /*
                                weekBorders is a string from two dates, start & end of the week, which is used for every wrapper instance
                            */

                            String weekBorders = tempDate.format() + ' - ' + tempDate.addDays(6).format();

                            /*
                                if we're dealing with the first week of the work period,
                                we calculate revenue, using the number of days between
                                the start date of the work period & the end of its week

                                then, if it's the last week, we use days between the end date of work period & the start of its week

                                else we just multiply revenue by 7 and subtract weekly cost price from it to get margin
                            */

                            for (Sales_Rate__c sr: orderItem.Sales_Rates__r) {
                                if (sr.Id == wp.Sales_Rate__c) {
                                    if (i == 0) {
                                        Integer firstWeekTillEnd = wp.Start_Date__c.daysBetween(firstWeekStart.addDays(6)) + 1;
                                        revenue = firstWeekTillEnd * sr.Sales_Price__c;
                                        margin = revenue - sr.Cost_Price__c * firstWeekTillEnd;
                                    } else if (i == weeksCount - 1) {
                                        Integer lastWeekTillEnd = lastWeekStart.daysBetween(wp.End_Date__c) + 1;
                                        revenue = lastWeekTillEnd * sr.Sales_Price__c;
                                        margin = revenue - sr.Cost_Price__c * lastWeekTillEnd;
                                    } else {
                                        revenue = sr.Sales_Price__c * 7;
                                        margin = revenue - sr.Cost_Price__c * 7;
                                    }
                                }
                            }

                            /*
                                once we get revenue, margin and period(weekBorders),
                                we add new instance of the wrapper to the list,
                                which then we'll use to put it with its related account as a key
                            */

                            weeklyRevenuesList.add(new RevenueWrapper(revenue, margin, weekBorders));
                            orderWeekBordersList.add(weekBorders);

                            /*
                                after we finish working with the current week, we repeat iteration for the next one,
                                incrementing it by 7
                                until the weekCount is reached
                            */
                            tempDate = tempDate.addDays(7);
                        }
                    }
                }
            }
            /*
                after the list was formed, we put the account name and its list in the map
            */
            groupedWeeklyRevenueMap.put(account, weeklyRevenuesList);

        }
        calculateTotal(groupedWeeklyRevenueMap);
        return groupedWeeklyRevenueMap;
    }

    static void calculateTotal(Map<String, List<RevenueWrapper>> groupedRevenueMap) {
        Decimal totalRevenue = 0;
        Decimal totalMargin = 0;

        for (String accountName : groupedRevenueMap.keySet()) {
            for (RevenueWrapper wrapper : groupedRevenueMap.get(accountName)) {
                totalRevenue += wrapper.revenue;
                totalMargin += wrapper.margin;
            }
        }

        groupedRevenueMap.put('TOTAL', new List<RevenueWrapper>{new RevenueWrapper(totalRevenue, totalMargin, null)});
    }

}
