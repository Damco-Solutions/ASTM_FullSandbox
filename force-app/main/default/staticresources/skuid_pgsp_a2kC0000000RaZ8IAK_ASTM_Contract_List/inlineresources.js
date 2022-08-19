(function(skuid){
skuid.snippet.register('HighlightRow',function(args) {var field = arguments[0], 

value = skuid.utils.decodeHTML(arguments[1]); 

skuid.ui.fieldRenderers[field.metadata.displaytype][field.mode](field,value); 

if (field.EndDate == 'read' && value < new Date()) 

    { 

        field.item.element.addClass("LeadTab_highlighted-row");


    }
});
}(window.skuid));