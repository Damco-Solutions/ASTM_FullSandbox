/**
 * Created by johnpernock from OpenGate Consulting on 2019-07-03.
 */
({
  doInit: function(cmp, event, helper) {
    var recordId = cmp.get("v.recordId");
    var getOppDetails = cmp.get("c.getOppDetails");
    getOppDetails.setParams({
      "recordId": recordId
    });
    getOppDetails.setCallback(this, function(response) {
      var state = response.getState();
      cmp.set("v.showSpinner", false);
      console.log("OppCloneComponentController getOppDetails callback");
      console.log("callback state: " + state);
      if (cmp.isValid() && state === "SUCCESS") {
        var oppDetails = response.getReturnValue();
        cmp.set("v.origOpp", oppDetails.opp);
        console.log(oppDetails.opp);
        if (oppDetails.opp.RecordType && oppDetails.opp.RecordType.Name.includes("IHS")) {
          cmp.set("v.ihsOpp", true);
        }
        if (oppDetails.oppLines !== undefined) {
          for (let i = 0; i < oppDetails.oppLines.length; i++) {
            let row = oppDetails.oppLines[i];
            console.log(row);
            // if (row.Product2Id)
            row.ProductName = row.Description;
            if (row.UnitPrice) {
              let price = row.UnitPrice;
              row.UnitPrice = price;
              row.NewSalesPrice = price * 1.03;
            }
            console.log(row);
          }
        }
        cmp.set("v.origOpplineItems", oppDetails.oppLines);
        cmp.set("v.columns", [
          { label: "Name", fieldName: "ProductName", type: "text", editable: false },
          { label: "Qty", fieldName: "Quantity", type: "number", editable: false, initialWidth: 80 },
          { label: "Curr Price", fieldName: "UnitPrice", type: "currency", editable: false, initialWidth: 120 },
          { label: "New Price", fieldName: "NewSalesPrice", type: "currency", editable: false, initialWidth: 120 }
        ]);
      } else if (state === "INCOMPLETE") {
        helper.showNotifyLibHelper(cmp, "Error!", "error", "Unknown error");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showNotifyLibHelper(cmp, "Error!", "error", errors[0].message);
          }
        } else {
          console.log("Unknown error");
          helper.showNotifyLibHelper(cmp, "Error!", "error", "Unknown error");
        }
      }
    });
    $A.enqueueAction(getOppDetails);
  },
  handleLoad: function(cmp, event, helper) {
    cmp.set("v.showSpinner", false);
  },
  updateOppLineItemPrice: function(cmp, event, helper) {
    var oppLines = cmp.get("v.origOpplineItems");
    var percentage = cmp.get("v.oppLinePercentageIncrease");
    for (var i = 0; i < oppLines.length; i++) {
      oppLines[i].NewSalesPrice = oppLines[i].UnitPrice * ((percentage / 100) + 1);
    }
    cmp.set("v.origOpplineItems", oppLines);
  },
  nextAction: function(cmp, event, helper) {
    cmp.set("v.showProducts", true);
  },
  prevAction: function(cmp, event, helper) {
    cmp.set("v.showProducts", false);
  },
  onSubmitAction: function(cmp, event, helper) {
    event.preventDefault();
    cmp.set("v.showSpinner", true);
    var oppLoadData = {};
    console.log("OnSubmitAction");
    console.log(oppLoadData);
    if (cmp.find("AccountId")) {
      oppLoadData.AccountId = Array.isArray(cmp.find("AccountId")) ? cmp.find("AccountId")[0].get("v.value") : cmp.find("AccountId").get("v.value");
    } else {
      oppLoadData.AccountId = null;
    }
    if (cmp.find("OwnerId")) {
      oppLoadData.OwnerId = Array.isArray(cmp.find("OwnerId")) ? cmp.find("OwnerId")[0].get("v.value") : cmp.find("OwnerId").get("v.value");
    } else {
      oppLoadData.OwnerId = null;
    }
    if (cmp.find("Name")) {
      oppLoadData.Name = Array.isArray(cmp.find("Name")) ? cmp.find("Name")[0].get("v.value") : cmp.find("Name").get("v.value");
    } else {
      oppLoadData.Name = null;
    }
    if (cmp.find("LeadSource")) {
      oppLoadData.LeadSource = Array.isArray(cmp.find("LeadSource")) ? cmp.find("LeadSource")[0].get("v.value") : cmp.find("LeadSource").get("v.value");
    } else {
      oppLoadData.LeadSource = null;
    }
    if (cmp.find("Description")) {
      oppLoadData.Description = Array.isArray(cmp.find("Description")) ? cmp.find("Description")[0].get("v.value") : cmp.find("Description").get("v.value");
    } else {
      oppLoadData.Description = null;
    }
    if (cmp.find("StageName")) {
      oppLoadData.StageName = Array.isArray(cmp.find("StageName")) ? cmp.find("StageName")[0].get("v.value") : cmp.find("StageName").get("v.value");
    } else {
      oppLoadData.StageName = null;
    }
    if (cmp.find("Probability")) {
      oppLoadData.Probability = Array.isArray(cmp.find("Probability")) ? Number(cmp.find("Probability")[0].get("v.value")) : Number(cmp.find("Probability").get("v.value"));
    } else {
      oppLoadData.Probability = 0.0;
    }
    if (cmp.find("CloseDate")) {
      oppLoadData.CloseDate = Array.isArray(cmp.find("CloseDate")) ? cmp.find("CloseDate")[0].get("v.value") : cmp.find("CloseDate").get("v.value");
    } else {
      oppLoadData.CloseDate = null;
    }
    if (cmp.find("Amount")) {
      oppLoadData.Amount = Array.isArray(cmp.find("Amount")) ? cmp.find("Amount")[0].get("v.value") : cmp.find("Amount").get("v.value");
    } else {
      oppLoadData.Amount = 0.0;
    }
    if (cmp.find("Demo__c")) {
      oppLoadData.Demo__c = Array.isArray(cmp.find("Demo__c")) ? cmp.find("Demo__c")[0].get("v.value") : cmp.find("Demo__c").get("v.value");
    } else {
      oppLoadData.Demo__c = null;
    }
    if (cmp.find("Number_Of_Locations__c")) {
      oppLoadData.Number_Of_Locations__c = Array.isArray(cmp.find("Number_Of_Locations__c")) ? cmp.find("Number_Of_Locations__c")[0].get("v.value") : cmp.find("Number_Of_Locations__c").get("v.value");
    } else {
      oppLoadData.Number_Of_Locations__c = null;
    }
    if (cmp.find("Number_Of_Potential_Locations__c")) {
      oppLoadData.Number_Of_Potential_Locations__c = Array.isArray(cmp.find("Number_Of_Potential_Locations__c")) ? cmp.find("Number_Of_Potential_Locations__c")[0].get("v.value") : cmp.find("Number_Of_Potential_Locations__c").get("v.value");
    } else {
      oppLoadData.Number_Of_Potential_Locations__c = null;
    }
    if (cmp.find("Number_of_Locations_Sold__c")) {
      oppLoadData.Number_of_Locations_Sold__c = Array.isArray(cmp.find("Number_of_Locations_Sold__c")) ? cmp.find("Number_of_Locations_Sold__c")[0].get("v.value") : cmp.find("Number_of_Locations_Sold__c").get("v.value");
    } else {
      oppLoadData.Number_of_Locations_Sold__c = null;
    }
    if (cmp.find("Purchase_Order_Number__c")) {
      oppLoadData.Purchase_Order_Number__c = Array.isArray(cmp.find("Purchase_Order_Number__c")) ? cmp.find("Purchase_Order_Number__c")[0].get("v.value") : cmp.find("Purchase_Order_Number__c").get("v.value");
    } else {
      oppLoadData.Purchase_Order_Number__c = null;
    }
    if (cmp.find("Subscription_Code_Type__c")) {
      oppLoadData.Subscription_Code_Type__c = Array.isArray(cmp.find("Subscription_Code_Type__c")) ? cmp.find("Subscription_Code_Type__c")[0].get("v.value") : cmp.find("Subscription_Code_Type__c").get("v.value");
    } else {
      oppLoadData.Subscription_Code_Type__c = null;
    }
    if (cmp.find("Are_IP_Addresses_Included__c")) {
      oppLoadData.Are_IP_Addresses_Included__c = Array.isArray(cmp.find("Are_IP_Addresses_Included__c")) ? cmp.find("Are_IP_Addresses_Included__c")[0].get("v.value") : cmp.find("Are_IP_Addresses_Included__c").get("v.value");
    } else {
      oppLoadData.Are_IP_Addresses_Included__c = null;
    }
    if (cmp.find("AR_Invoice_Type__c")) {
      oppLoadData.AR_Invoice_Type__c = Array.isArray(cmp.find("AR_Invoice_Type__c")) ? cmp.find("AR_Invoice_Type__c")[0].get("v.value") : cmp.find("AR_Invoice_Type__c").get("v.value");
    } else {
      oppLoadData.AR_Invoice_Type__c = null;
    }
    if (cmp.find("Required_Log_In__c")) {
      oppLoadData.Required_Log_In__c = Array.isArray(cmp.find("Required_Log_In__c")) ? cmp.find("Required_Log_In__c")[0].get("v.value") : cmp.find("Required_Log_In__c").get("v.value");
    } else {
      oppLoadData.Required_Log_In__c = null;
    }
    if (cmp.find("Industry_Tag__c")) {
      oppLoadData.Industry_Tag__c = Array.isArray(cmp.find("Industry_Tag__c")) ? cmp.find("Industry_Tag__c")[0].get("v.value") : cmp.find("Industry_Tag__c").get("v.value");
    } else {
      oppLoadData.Industry_Tag__c = null;
    }
    if (cmp.find("Field_Suppression__c")) {
      oppLoadData.Field_Suppression__c = Array.isArray(cmp.find("Field_Suppression__c")) ? cmp.find("Field_Suppression__c")[0].get("v.value") : cmp.find("Field_Suppression__c").get("v.value");
    } else {
      oppLoadData.Field_Suppression__c = null;
    }
    if (cmp.find("Usage_Admin_Name__c")) {
      oppLoadData.Usage_Admin_Name__c = Array.isArray(cmp.find("Usage_Admin_Name__c")) ? cmp.find("Usage_Admin_Name__c")[0].get("v.value") : cmp.find("Usage_Admin_Name__c").get("v.value");
    } else {
      oppLoadData.Usage_Admin_Name__c = null;
    }
    if (cmp.find("Usage_Admin_Email__c")) {
      oppLoadData.Usage_Admin_Email__c = Array.isArray(cmp.find("Usage_Admin_Email__c")) ? cmp.find("Usage_Admin_Email__c")[0].get("v.value") : cmp.find("Usage_Admin_Email__c").get("v.value");
    } else {
      oppLoadData.Usage_Admin_Email__c = null;
    }
    if (cmp.find("Usage_Viewed_By__c")) {
      oppLoadData.Usage_Viewed_By__c = Array.isArray(cmp.find("Usage_Viewed_By__c")) ? cmp.find("Usage_Viewed_By__c")[0].get("v.value") : cmp.find("Usage_Viewed_By__c").get("v.value");
    } else {
      oppLoadData.Usage_Viewed_By__c = null;
    }
    if (cmp.find("Registration_Form__c")) {
      oppLoadData.Registration_Form__c = Array.isArray(cmp.find("Registration_Form__c")) ? cmp.find("Registration_Form__c")[0].get("v.value") : cmp.find("Registration_Form__c").get("v.value");
    } else {
      oppLoadData.Registration_Form__c = null;
    }
    if (cmp.find("IP_Addresses__c")) {
      oppLoadData.IP_Addresses__c = Array.isArray(cmp.find("IP_Addresses__c")) ? cmp.find("IP_Addresses__c")[0].get("v.value") : cmp.find("IP_Addresses__c").get("v.value");
    } else {
      oppLoadData.IP_Addresses__c = null;
    }
    if (cmp.find("Applet_URL__c")) {
      oppLoadData.Applet_URL__c = Array.isArray(cmp.find("Applet_URL__c")) ? cmp.find("Applet_URL__c")[0].get("v.value") : cmp.find("Applet_URL__c").get("v.value");
    } else {
      oppLoadData.Applet_URL__c = null;
    }
    if (cmp.find("Notify_for_Renewal__c")) {
      oppLoadData.Notify_for_Renewal__c = Array.isArray(cmp.find("Notify_for_Renewal__c")) ? cmp.find("Notify_for_Renewal__c")[0].get("v.value") : cmp.find("Notify_for_Renewal__c").get("v.value");
    } else {
      oppLoadData.Notify_for_Renewal__c = null;
    }
    if (cmp.find("Watermark__c")) {
      oppLoadData.Watermark__c = Array.isArray(cmp.find("Watermark__c")) ? cmp.find("Watermark__c")[0].get("v.value") : cmp.find("Watermark__c").get("v.value");
    } else {
      oppLoadData.Watermark__c = null;
    }
    if (cmp.find("Member_Dashboard_Domain__c")) {
      oppLoadData.Member_Dashboard_Domain__c = Array.isArray(cmp.find("Member_Dashboard_Domain__c")) ? cmp.find("Member_Dashboard_Domain__c")[0].get("v.value") : cmp.find("Member_Dashboard_Domain__c").get("v.value");
    } else {
      oppLoadData.Member_Dashboard_Domain__c = null;
    }
    if (cmp.find("Member_Dashboard_Domain__c")) {
      oppLoadData.DRM__c = Array.isArray(cmp.find("DRM__c")) ? cmp.find("DRM__c")[0].get("v.value") : cmp.find("DRM__c").get("v.value");
    } else {
      oppLoadData.DRM__c = null;
    }
    if (cmp.find("Member_Dashboard_Domain__c")) {
      oppLoadData.Custom_Settings__c = Array.isArray(cmp.find("Custom_Settings__c")) ? cmp.find("Custom_Settings__c")[0].get("v.value") : cmp.find("Custom_Settings__c").get("v.value");
    } else {
      oppLoadData.Custom_Settings__c = null;
    }
    if (cmp.find("Member_Dashboard_Domain__c")) {
      oppLoadData.Shibboleth_Open_Athens_URL__c = Array.isArray(cmp.find("Shibboleth_Open_Athens_URL__c")) ? cmp.find("Shibboleth_Open_Athens_URL__c")[0].get("v.value") : cmp.find("Shibboleth_Open_Athens_URL__c").get("v.value");
    } else {
      oppLoadData.Shibboleth_Open_Athens_URL__c = null;
    }
    if (cmp.find("Type")) {
      oppLoadData.Type = Array.isArray(cmp.find("Type")) ? cmp.find("Type")[0].get("v.value") : cmp.find("Type").get("v.value");
    } else {
      oppLoadData.Type = null;
    }
    if (cmp.find("Contract_Required__c")) {
      oppLoadData.Contract_Required__c = Array.isArray(cmp.find("Contract_Required__c")) ? cmp.find("Contract_Required__c")[0].get("v.value") : cmp.find("Contract_Required__c").get("v.value");
    } else {
      oppLoadData.Contract_Required__c = null;
    } 
      //Modified by Damco for Account Details
       if (cmp.find("Account_Street__c")) {
      oppLoadData.Account_Street__c = Array.isArray(cmp.find("Account_Street__c")) ? cmp.find("Account_Street__c")[0].get("v.value") : cmp.find("Account_Street__c").get("v.value");
    } else {
      oppLoadData.Account_Street__c = null;
    }
      if (cmp.find("Community_Account__c")) {
      oppLoadData.Community_Account__c = Array.isArray(cmp.find("Community_Account__c")) ? cmp.find("Community_Account__c")[0].get("v.value") : cmp.find("Community_Account__c").get("v.value");
    } else {
      oppLoadData.Community_Account__c = null;
    }
      if (cmp.find("Account_City__c")) {
      oppLoadData.Account_City__c = Array.isArray(cmp.find("Account_City__c")) ? cmp.find("Account_City__c")[0].get("v.value") : cmp.find("Account_City__c").get("v.value");
    } else {
      oppLoadData.Account_City__c = null;
    }
      if (cmp.find("Account_State__c")) {
      oppLoadData.Account_State__c = Array.isArray(cmp.find("Account_State__c")) ? cmp.find("Account_State__c")[0].get("v.value") : cmp.find("Account_State__c").get("v.value");
    } else {
      oppLoadData.Account_State__c = null;
    }
      if (cmp.find("Account_Postal_Code__c")) {
      oppLoadData.Account_Postal_Code__c = Array.isArray(cmp.find("Account_Postal_Code__c")) ? cmp.find("Account_Postal_Code__c")[0].get("v.value") : cmp.find("Account_Postal_Code__c").get("v.value");
    } else {
      oppLoadData.Account_Postal_Code__c = null;
    }
      if (cmp.find("Account_Country__c")) {
      oppLoadData.Account_Country__c = Array.isArray(cmp.find("Account_Country__c")) ? cmp.find("Account_Country__c")[0].get("v.value") : cmp.find("Account_Country__c").get("v.value");
    } else {
      oppLoadData.Account_Country__c = null;
    }
      if (cmp.find("Existing_Revenue__c")) {
      oppLoadData.Existing_Revenue__c = Array.isArray(cmp.find("Existing_Revenue__c")) ? cmp.find("Existing_Revenue__c")[0].get("v.value") : cmp.find("Existing_Revenue__c").get("v.value");
    } else {
      oppLoadData.Existing_Revenue__c = null;
    }
//        if (cmp.find("Contract_End_Date__c")){
//            oppLoadData.Contract_End_Date__c = cmp.find("Contract_End_Date__c").get("v.value");
//        }else{
//            oppLoadData.Contract_End_Date__c = null;
//        }
//        if (cmp.find("Number_of_Months__c")){
//            oppLoadData.Number_of_Months__c = cmp.find("Number_of_Months__c").get("v.value");
//        }else{
//            oppLoadData.Number_of_Months__c = null;
//        }

    console.log(oppLoadData);

    var percentageIncrease = cmp.get("v.oppLinePercentageIncrease");
    var lineItems = cmp.get("v.origOpplineItems");
    var origOpp = cmp.get("v.origOpp");

    var saveOppDetails = cmp.get("c.saveCloneOppData");
    saveOppDetails.setParams({
      "jsonOpp": JSON.stringify(origOpp),
      "jsonLineItems": JSON.stringify(lineItems),
      "jsonUpdatedFields": JSON.stringify(oppLoadData),
      "percentageIncrease": percentageIncrease
    });
    saveOppDetails.setCallback(this, function(response) {
      var state = response.getState();
      cmp.set("v.showSpinner", false);
      console.log("OppCloneComponentController saveCloneOppData callback");
      console.log("callback state: " + state);
      if (cmp.isValid() && state === "SUCCESS") {
        var oppCreatedId = response.getReturnValue();
        console.log(oppCreatedId);
        if (oppCreatedId) {
          var navEvt = $A.get("e.force:navigateToSObject");
          navEvt.setParams({
            "recordId": oppCreatedId,
            "slideDevName": "detail"
          });
          navEvt.fire();
        }
      } else if (state === "INCOMPLETE") {
        helper.showNotifyLibHelper(cmp, "Error!", "error", "Unknown error");
      } else if (state === "ERROR") {
        var errors = response.getError();
        console.log(errors);
        if (errors) {
          if (errors[0]) {
            console.log(errors[0]);
            if (errors[0].message) {
              console.log("Error message: " + errors[0].message);
              if (errors[0].exceptionType && errors[0].stackTrace) {
                helper.showNotifyLibHelper(cmp, errors[0].exceptionType, "error", errors[0].exceptionType + " - " + errors[0].message + " - " + errors[0].stackTrace);
              } else {
                helper.showNotifyLibHelper(cmp, "Error", "error", errors[0].message);
              }
            } else if (errors[0].pageErrors[0] !== undefined) {
              var pageError = errors[0].pageErrors[0];
              console.log(pageError);
              if (pageError) {
                helper.showNotifyLibHelper(cmp, pageError.statusCode, "error", pageError.message);
              }
            } else if (errors[0].fieldErrors) {
              var fieldError = errors[0].fieldErrors;
              var keys = Object.keys(fieldError);
              console.log(keys);
              for (var i = 0; i < keys.length; i++) {
                var key = keys[i];
                console.log(key);
                var error = fieldError[key][0];
                console.log(error);
                helper.showNotifyLibHelper(cmp, error.statusCode, "error", key + " - " + error.message);
              }
            }
          }
        } else {
          console.log("Unknown error");
          helper.showNotifyLibHelper(cmp, "Error!", "error", "Unknown error");
        }
      }
    });
    $A.enqueueAction(saveOppDetails);
  }
});