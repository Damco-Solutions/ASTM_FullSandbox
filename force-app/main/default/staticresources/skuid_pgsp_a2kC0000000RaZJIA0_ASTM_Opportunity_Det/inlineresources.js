(function(skuid){
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
});
});
}(window.skuid));