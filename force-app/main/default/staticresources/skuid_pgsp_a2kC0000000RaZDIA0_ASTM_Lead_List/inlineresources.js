(function(skuid){
skuid.snippet.register('Chart%Snip',function(args) {var chartObj = arguments[0],

	$ = skuid.$;


$.extend(true, chartObj.plotOptions,{

        pie: {

            dataLabels: {

                enabled: true,

                formatter: function () {

                    '%';

                    }

            }

        }

});


$.extend(chartObj,{

    tooltip: {

        enabled:false

    }    

});
});
}(window.skuid));