(function(skuid){
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){

var contractModel = skuid.model.getModel('Contract');
var contractRow = contractModel.getFirstRow();
var contractStatus = contractModel.getFieldValue(contractRow, 'Status');

if(contractStatus === 'Activated'){

	    $.each(skuid.component.getByType('basicfieldeditor'), function(i, v) {
        v.element.mode = 'readonly';
        v.element.list.render({doNotCache: true});
    });
}

	});	
})(skuid);;
}(window.skuid));