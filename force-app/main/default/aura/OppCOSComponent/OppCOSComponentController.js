/**
 * Created by johnpernock from OpenGate Consulting on 2019-07-03.
 */
({
    doInit: function(cmp, event, helper) {
        var recordId = cmp.get('v.recordId');
        var cloneOrigOpp = cmp.get('c.cloneOriginalOpp');
        cloneOrigOpp.setParams({
            "recordId": recordId
        });
        cloneOrigOpp.setCallback(this, function(response) {
            var state = response.getState();
            console.log("callback state: " + state);
            if (cmp.isValid() && state === "SUCCESS") {
                var oppId = response.getReturnValue();
                cmp.set('v.newOppId', oppId);
            }
            else if (state === "INCOMPLETE") {
                        helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(cmp, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
                }
            }
         });
        $A.enqueueAction(cloneOrigOpp);
    },
    handleCancel: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOnSuccess: function(cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": cmp.get('v.newOppId'),
              "slideDevName": "detail"
            });
            navEvt.fire();
    }
})