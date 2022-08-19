(function(skuid){
(function(skuid){
	var $ = skuid.$;
	$(document.body).one('pageload',function(){
	    skuid.model.map().Activities.load();
		skuid.events.subscribeOnce('models.loaded',function(saveResult){
            if ('Activities' in saveResult.models){
                skuid.model.map().ContactActivities.load();
            }
        });
        skuid.events.subscribe('models.loaded', function(saveResult){
           if ('ContactActivities' in saveResult.models){
            skuid.model.map().Activities.adoptRows(skuid.model.map().ContactActivities.data);
        } 
        });
	});
})(skuid);;
}(window.skuid));