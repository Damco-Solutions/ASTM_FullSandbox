(function(skuid){
skuid.snippet.register('sendActOnEmail',function(args) {var lead = skuid.model.map().Lead.data[0];
console.log(sforce.connection.partnerServerUrls);
invokeWithActOnUrl( function(url) 
{ 
url += '/acton/sforce/sendSforceContactOrLead.jsp?id='+lead.Id+'&server='+sforce.connection.partnerServerUrls[19]+'&session='+skuid.utils.userInfo.sessionId;
window.open(url,"_blank", "width=1200,height=768");
});

function invokeWithActOnUrl(func){
	var callback = { 
		onSuccess: function(result){func(result);},
		onFailure: function(){func("https://sf.actonsoftware.com");}
	} 
	sforce.apex.execute('ActOn/ActonWebService','getServerUrl',{}, callback);	
}
});
}(window.skuid));