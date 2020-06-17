public with sharing class CalculateRevenue {

    public static Map<String, List<WeeklyRevenue>> getWeeklyRevenue(Map <String, List <Order__c>> groupedOrdersMap) {
        Map<String, List<WeeklyRevenue>> groupedWeeklyRevenueMap = new Map<String, List<WeeklyRevenue>>();
        for (String account: groupedOrdersMap.keySet()) {
            List < WeeklyRevenue > weeklyRevenuesList = new List < WeeklyRevenue > ();
            for (Order__c orderItem: groupedOrdersMap.get(account)) {

                for (Work_Period__c wp: orderItem.Work_Periods__r) {
                    List < String > orderWeekBordersList = new List < String > ();
                    Decimal revenue = 0;
                    Decimal margin = 0;
                    if (wp.End_Date__c <= (wp.Start_Date__c.toStartofWeek().addDays(6))) {
                        for (Sales_Rate__c sr: orderItem.Sales_Rates__r) {
                            if (sr.Id == wp.Sales_Rate__c) {
                                revenue = sr.Sales_Price__c * (wp.Start_Date__c.daysBetween(wp.End_Date__c) + 1);
                                margin = revenue - sr.Cost_Price__c * (wp.Start_Date__c.daysBetween(wp.End_Date__c) + 1);
                                weeklyRevenuesList.add(new WeeklyRevenue(revenue, margin, wp.Start_Date__c.format() + ' - ' + wp.Start_Date__c.addDays(6).format()));
                            }
                        }

                    } else {
                        Date firstWeekStart = wp.Start_Date__c.toStartofWeek();
                        Date lastWeekStart = wp.End_Date__c.toStartofWeek();
                        Integer weeksCount = firstWeekStart.daysBetween(lastWeekStart) / 7 + 1;
                        Date tempDate2 = firstWeekStart;

                        for (Integer i = 0; i < weeksCount; i++) {

                            String weekBorders = tempDate2.format() + ' - ' + tempDate2.addDays(6).format();
                            for (Sales_Rate__c sr: orderItem.Sales_Rates__r) {
                                if (sr.Id == wp.Sales_Rate__c) {
                                    if (i == 0) {
                                        Integer firstWeekTillEnd = (wp.Start_Date__c.daysBetween(firstWeekStart.addDays(6)) + 1);
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
                            weeklyRevenuesList.add(new WeeklyRevenue(revenue, margin, weekBorders));
                            orderWeekBordersList.add(weekBorders);
                            tempDate2 = tempDate2.addDays(7);
                        }
                    }
                }
            }
            groupedWeeklyRevenueMap.put(account, weeklyRevenuesList);
        }
        return groupedWeeklyRevenueMap;
    }

    class WeeklyRevenue {
        Decimal revenue;
        Decimal margin;
        String week;

        weeklyRevenue(Decimal revenue, Decimal margin, String week) {
            this.revenue = revenue;
            this.margin = margin;
            this.week = week;
        }
    }
}