import { LightningElement } from 'lwc';
import getWeeklyRevenueReport from '@salesforce/apex/RevenueReportController.getWeeklyRevenueReport';

export default class RevenueReport extends LightningElement {
    theList;

    connectedCallback() {
        getWeeklyRevenueReport()
            .then((result) => {
                let parsedResult = JSON.parse(result);
                this.theList = Object.keys(parsedResult).map(i => ({
                    account: i,
                    orders: parsedResult[i]
                }));
                console.log('theList : ',this.theList);

            }).catch((err) => {
                console.error(err);
            })
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
        this.theList.push({account: 'TOTAL', orders: [{
                                                revenue: totalRevenue,
                                                margin: totalMargin
                                            }]
        });
    }


}
