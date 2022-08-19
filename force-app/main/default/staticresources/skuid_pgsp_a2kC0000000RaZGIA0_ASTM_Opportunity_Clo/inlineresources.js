(function(skuid){
skuid.snippet.register('adjustPriceProducts',function(args) {var params = arguments[0],
	$ = skuid.$;

var productModel = skuid.model.map().Products;
var products = productModel.data;

var opportunityModel = skuid.model.map().Opportunity;
var opportunity = opportunityModel.data[0];

var percentage = 3;

if (opportunity.Price_Adjustment !== '' && opportunity.Price_Adjustment !== null && opportunity.Price_Adjustment !== undefined){
    percentage = opportunity.Price_Adjustment;
}

console.log(percentage);


$.each(products, function(i, row){
   
   var unitPrice = row.UnitPrice * ((percentage / 100) + 1);
   console.log(row.UnitPrice);
   console.log(unitPrice);
   
   productModel.updateRow(row, 'New_Sale_Price', unitPrice);
});
});
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
		var opportunityModel = skuid.model.map().Opportunity;
var opportunity = opportunityModel.data[0];

opportunityModel.updateRow(opportunity, 'Price_Adjustment', 3.00);
	});
})(skuid);;
skuid.snippet.register('updateProductPrices',function(args) {var params = arguments[0],
	$ = skuid.$;

var productModel = skuid.model.map().Products;
var products = productModel.data;

$.each(products, function(i, row){
   productModel.updateRow(row, 'UnitPrice', row.New_Sale_Price);
});
});
}(window.skuid));