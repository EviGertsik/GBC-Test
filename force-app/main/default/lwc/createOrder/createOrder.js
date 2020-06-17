import {
    LightningElement
} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class createOrder extends LightningElement {
    orderId;
    isPeriodFormRendered = false;

    handleOrderCreate(event) {
        this.orderId = event.detail.id;
        this.showToast('Order Has Been Created');
    }

    handleRateCreate() {
        this.isPeriodFormRendered = true;
        this.showToast('Sales Rate Has Been Created');
    }

    handlePeriodCreate() {
        this.showToast('Work Period Has Been Created');
    }

    showToast(param) {
        const toastEvent = new ShowToastEvent({
            title: param
        });
        this.dispatchEvent(toastEvent);
    }


}