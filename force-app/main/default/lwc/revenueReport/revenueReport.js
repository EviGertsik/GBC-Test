import { LightningElement } from 'lwc';
import getOrders from '@salesforce/apex/RevenueReportController.getOrders';

export default class RevenueReport extends LightningElement {
    theList;

    renderedCallback() {
        getOrders()
            .then((result) => {
                let parsedResult = JSON.parse(result);
                this.theList = Object.keys(parsedResult).map(i => ({
                    account: i,
                    orders: parsedResult[i]
                }));
                this.calculateTotals(this.theList);
            }).catch((err) => {
                this.error = err;
            });
    }

    calculateTotals(param) {
        let totalRevenue = 0;
        let totalMargin = 0;
        param.forEach(element => {
            element.orders.forEach(subElement => {
                totalRevenue += subElement.revenue;
                totalMargin += subElement.margin;
            })
        });
        let obj = [{
            revenue: totalRevenue, 
            margin: totalMargin
        }]
        this.theList.push({account: 'TOTAL', orders: obj});
    }
}