/**
 * Created by johnpernock from OpenGate Consulting on 2019-08-26.
 */

({
    initAction : function(component, event, helper) {
        component.find("load_spinner").set("v.class" , 'slds-show');
        let recordId = component.get('v.recordId');

        component.set('v.columns', [
           {label: 'OrderNo', fieldName: 'OrderNo', type: 'text', initialWidth : 100},
           {label: 'OrderCategoryCode', fieldName: 'OrderCategoryCode', type: 'text', initialWidth : 100},
           {label: 'BillToCustomer', fieldName: 'BillToCustomer', type: 'text', initialWidth : 100},
           {label: 'BillToAddress', fieldName: 'BillToAddress', type: 'text', initialWidth : 200},
           {label: 'PrepayInformation', fieldName: 'PrepayInformation', type: 'text', initialWidth : 200},
           {label: 'ShipMethod', fieldName: 'ShipMethod', type: 'text', initialWidth : 200},
           {label: 'ShipToAddress', fieldName: 'ShipToAddress', type: 'text', initialWidth : 200},
           {label: 'ShipToCustomer', fieldName: 'ShipToCustomer', type: 'text', initialWidth : 120},
           {label: 'ShipToLocation', fieldName: 'ShipToLocation', type: 'text', initialWidth : 120},
           {label: 'Shipper', fieldName: 'Shipper', type: 'text', initialWidth : 120},
           {label: 'TimeStamp', fieldName: 'TimeStamp', type: 'text', initialWidth : 200},
           {label: 'Tracking', fieldName: 'Tracking', type: 'text', initialWidth : 100},
           {label: 'GrandTotal', fieldName: 'GrandTotal', type: 'currency', initialWidth : 150}
        ]);

        let getOrderHistory = component.get('c.getOrderHistory');
        getOrderHistory.setParams({
            "accountId": recordId
        });
        getOrderHistory.setCallback(this, function(response) {
            let state = response.getState();
            component.find("load_spinner").set("v.class" , 'slds-hide');
            console.log("callback state: " + state);
            if (component.isValid() && state === "SUCCESS") {
                console.log('Data Return');
                let responseData = response.getReturnValue();
                if (responseData != null && responseData !== '' && responseData !== undefined){
                    let returnData = JSON.parse(responseData);
                    console.log(returnData.OrderDetail);
                    let orderHistory = returnData.OrderDetail;
                    if (orderHistory != null){
                        orderHistory.sort(function(a, b) {
                            return parseFloat(b.OrderNo) - parseFloat(a.OrderNo);
                        });
                        if (component.get('v.showRoyaltyPaymentsOnly') === true){
                            let historyUpdate = [];
                            for (let idx in orderHistory){
                                let order = orderHistory[idx];
                                if (order.Items){
                                    for (let itemIdx in order.Items){
                                        let item = order.Items[itemIdx];
                                        console.log(item);
                                        if (item.ItemName && item.ItemName === 'ROYALTIES'){
                                            historyUpdate.push(order);
                                            break;
                                        }
                                    }
                                }
                            }
                            orderHistory = historyUpdate;
                        } else {
                            let historyUpdate = [];
                            for (let idx in orderHistory){
                                let order = orderHistory[idx];
                                if (order.Items){
                                    for (let itemIdx in order.Items){
                                        let item = order.Items[itemIdx];
                                        console.log(item);
                                        if (item.ItemName && item.ItemName !== 'ROYALTIES'){
                                            historyUpdate.push(order);
                                            break;
                                        }
                                    }
                                }
                            }
                            orderHistory = historyUpdate;
                        }
                        if (orderHistory.length === 0){
                            component.set('v.showNoData', true);
                        }
                    }else{
                        component.set('v.showNoData', true);
                    }
                    component.set('v.data', orderHistory);
                }else{
                     component.set('v.showNoData', true);
                 }
            }
            else if (state === "INCOMPLETE") {
                helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(component, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
                }
            }
         });
        $A.enqueueAction(getOrderHistory);
    }
});