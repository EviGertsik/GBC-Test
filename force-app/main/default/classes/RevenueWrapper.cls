public with sharing class RevenueWrapper {

    public Decimal revenue;
    public Decimal margin;
    public String period;

    public RevenueWrapper(Decimal revenue, Decimal margin, String period) {
        this.revenue = revenue;
        this.margin = margin;
        this.period = period;
    }
}
