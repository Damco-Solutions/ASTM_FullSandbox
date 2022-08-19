(function(skuid){
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
		var opportunityModel = skuid.model.map().Opportunity;
        var opportunity = opportunityModel.data[0];
        
        opportunityModel.updateRow(opportunity, 'Price_Adjustment', 0.00);
        console.log('Params');
        console.log(skuid.page.params.type);
        if (skuid.page.params.type == 'COS'){
            var currentName = opportunity.Name;
            var cosCount = skuid.model.map().OpportunityCOS.data.length + 1;
            opportunityModel.updateRow(opportunity, 'Type', 'Expansion');
            opportunityModel.updateRow(opportunity, 'Change_of_Scope__c', true);
            opportunityModel.updateRow(opportunity, 'Name', currentName + '--COS' + cosCount);
            opportunityModel.updateRow(opportunity, 'Original_Opportunity__c', skuid.page.params.id);
            opportunityModel.updateRow(opportunity, 'Pricebook2Id', skuid.model.map().COSPricebook.data[0].Id);
            //skuid.model.map().Products.abandonAllRows();
            //skuid.model.map().Products.adoptRows(skuid.model.map().OriginalOppProducts.data);
            
            //$.each(skuid.model.map().OriginalOppProducts.data, function( index, row ) {
                // var newrow = skuid.model.map().Products.createRow({
                //     additionalConditions: [
                //             {field : 'ProductCode', value : row.ProductCode},
                //             {field : 'Quantity', value : row.Quantity},
                //             {field : 'Product2Id', value : row.Product2Id},
                //             {field : 'ListPrice', value : row.UnitPrice},
                //             {field : 'UnitPrice', value : row.UnitPrice},
                //             {field : 'Description', value : row.Description},
                //             {field : 'ServiceDate', value : row.ServiceDate},
                //             {field : 'TotalPrice', value : row.TotalPrice}
                //     ]
                // });
            //     skuid.model.map().Products.updateRow(row, 'OpportunityId', null);
            //     console.log(row);
            // });
        }
	});
})(skuid);;
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
skuid.snippet.register('updateProductPrices',function(args) {var params = arguments[0],
	$ = skuid.$;

var productModel = skuid.model.map().Products;
var products = productModel.data;

$.each(products, function(i, row){
   productModel.updateRow(row, 'UnitPrice', row.New_Sale_Price);
});
});
skuid.snippet.register('newProductsIfSaved',function(args) {var params = arguments[0],
	$ = skuid.$;

var opp = skuid.model.map().Opportunity.data[0];

if (!skuid.model.map().Opportunity.isRowNew(opp)){
    return true;
}else{
    return false;
}
});
}(window.skuid));