(function(skuid){
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
		//get Oracle account number
		var accountModel = skuid.$M('AccountOrderHistory');
		var accountRow = accountModel.getFirstRow();
		//get date parameters
		var dateModel = skuid.$M('DatePrompt');
		var dateRow = dateModel.getFirstRow();

		var getOrderParams = {
			    accountNumber: accountRow.Oracle_Account_Number__c,
			    dateFrom: dateRow.DateFrom || '',
			    dateTo: dateRow.DateTo || ''
			};

		console.log(getOrderParams);

    $.when(getOrderData(getOrderParams)).then(function(result){
        console.log('should be a result');
        console.log(result[0]);
	    var records = JSON.parse(result[0]);
        console.log(records.OrderDetail);

	    $.each(records.OrderDetail, function(i, v) {
	        console.log(v);

			var conditions =   [
			   {field: 'BillToAddress', value: v.BillToAddress},
			   {field: 'BillToCustomer', value: v.BillToCustomer},
			   {field: 'BillToLocation', value: v.BillToLocation},
			   {field: 'GrandTotal', value: v.GrandTotal},
			   {field: 'OrderCategoryCode', value: v.OrderCategoryCode},
			   {field: 'OrderNo', value: v.OrderNo},
			   {field: 'PrepayInformation', value: v.PrepayInformation},
			   {field: 'ShipMethod', value: v.ShipMethod},
			   {field: 'ShipToAddress', value: v.ShipToAddress},
			   {field: 'ShipToCustomer', value: v.ShipToCustomer},
			   {field: 'ShipToLocation', value: v.ShipToLocation},
			   {field: 'Shipper', value: v.Shipper},
			   {field: 'TimeStamp', value: v.TimeStamp},
			   {field: 'Tracking', value: v.Tracking}

			];

			skuid.model.map().OrderHistory.createRow({

			   additionalConditions: conditions
			});
			//https://community.skuid.com/skuid/topics/table-allow-ordering-for-ui-only-formula-fields
	    });
	    var model = skuid.$M('OrderHistory');
        var rows = model.getRows();
        model.abandonAllRows(); //remove rows from the original model
        var sortedRows = rows.sort(sort__ByField_DESC);
        model.adoptRows(sortedRows); //add them back sorted
    });

	});
})(skuid);

/**
 * @description Converts a string response to an array of objects.
 * @param {string} string - The string you want to convert.
 * @returns {array} - an array of objects.
*/
function stringToJson(input) {
  var result = [];

  //replace leading and trailing [], if present
  input = input.replace(/^\[/,'');
  input = input.replace(/\]$/,'');

  //change the delimiter to 
  input = input.replace(/},{/g,'};;;{');

  // preserve newlines, etc - use valid JSON
  //https://stackoverflow.com/questions/14432165/uncaught-syntaxerror-unexpected-token-with-json-parse
input = input.replace(/\\n/g, "\\n")  
.replace(/\\'/g, "\\'")
.replace(/\\"/g, '\\"')
.replace(/\\&/g, "\\&")
.replace(/\\r/g, "\\r")
.replace(/\\t/g, "\\t")
.replace(/\\b/g, "\\b")
.replace(/\\f/g, "\\f");
// remove non-printable and other non-valid JSON chars
input = input.replace(/[\u0000-\u0019]+/g,""); 

  input = input.split(';;;');

  input.forEach(function(element) {
    // console.log(JSON.stringify(element));

    result.push(JSON.parse(element));
  }, this);

  return result;
}
//function to retrieve data from web service
function getOrderData(orderParams) {
 	var result = sforce.apex.execute(
		'OrderHistoryService',
		'getOrderHistoryData',
		orderParams
	);
//   console.log(result[0]);
   return result;
}
//function to sort by field Descending
function sort__ByField_DESC(a,b){
    //Change this to the field you need to sort
    var field = 'OrderNo';
    if( a[field] < b[field] ) return -1;
    if( a[field] > b[field] ) return 1;
    return 0;
};
}(window.skuid));