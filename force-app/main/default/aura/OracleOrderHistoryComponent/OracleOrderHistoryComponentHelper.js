/**
 * Created by johnpernock from OpenGate Consulting on 2019-08-26.
 */

({
    showNotifyLibHelper : function(component, msgTitle, msgType, msg) {
            component.find('notifLib').showNotice({
                "variant": msgType,
                "header": msgTitle,
                "message": msg,
                closeCallback: function() {
                    console.log('Alert Closed');
                }
            });
        },
});