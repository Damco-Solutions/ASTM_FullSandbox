(function(skuid){
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
		var opportunityModel = skuid.model.map().Opportunity;
        var opportunity = opportunityModel.data[0];
        
        opportunityModel.updateRow(opportunity, 'Price_Adjustment', 3.00);
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
            skuid.model.map().Products.abandonAllRows();
        }else{
            if (opportunity.Change_of_Scope__c === true){
                skuid.model.map().Products.abandonAllRows();
            }
        }
        
        var duplicates = [];
        for (j=0;j<skuid.model.map().Products.data.length;j++){
            for (k=j+1;k<skuid.model.map().Products.data.length;k++){
                if (k!=j && skuid.model.map().Products.data[k].Product2Id == skuid.model.map().Products.data[j].Product2Id){
                    if(!duplicates.includes(skuid.model.map().Products.data[k])){
                        duplicates.push(skuid.model.map().Products.data[k]);
                    }
                }
            }
        }
        skuid.model.map().Products.abandonRows(duplicates);
        
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

var opp = skuid.model.map().Opportunity.data[0];
var productModel = skuid.model.map().Products;
var products = productModel.data;
var priceBookEntries = skuid.model.map().PricebookEntriesForProducts.data;

$.each(products, function(i, product){
    console.log(product);
   productModel.updateRow(product, 'UnitPrice', product.New_Sale_Price);
   if (product.PricebookEntry.Pricebook2Id !== opp.Pricebook2Id){
       $.each(priceBookEntries, function(j, pricebookEntry){
           if (pricebookEntry.Product2Id == product.Product2Id){
               productModel.updateRow(product, 'PricebookEntryId', pricebookEntry.Id);
               productModel.updateRow(product, 'PricebookEntry', pricebookEntry);
           }
       });
   }
});
});
skuid.snippet.register('addSelectedOppLines',function(args) {var params = arguments[0],
	$ = skuid.$;

var selectedProductsModel = skuid.model.map().SelectedProducts;
var selectedProducts = selectedProductsModel.data;

var oppLineModel = skuid.model.map().NewOpLineItems;
var oppLines = oppLineModel.data;

var oppModel = skuid.model.map().Opportunity;
var opportunity = oppModel.data[0];

$.each(selectedProducts, function(i, rowData){
    var newQppLine = oppLineModel.createRow({
        additionalConditions: [
            {field : 'PricebookEntryId', value : rowData.Id},
            {field : 'PricebookEntryId__r', value : rowData},
            {field : 'OpportunityId', value : opportunity.Id},
            {field : 'OpportunityId__r', value : opportunity},
            {field : 'ListPrice', value : rowData.UnitPrice},
            {field : 'UnitPrice', value : rowData.UnitPrice}
        ]
    });
    console.log(newQppLine);
});
});
}(window.skuid));