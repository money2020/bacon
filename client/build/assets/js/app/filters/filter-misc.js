(function(){app.filter("removeZerosFromMoney",function(){return function(text){return text.slice(0,-3)}}),app.filter("limit",function(){return function(array,lowerBound,upperBound){var _ref;return array?(2===arguments.length&&(_ref=function(){return _.isObject(lowerBound)?[lowerBound.left,lowerBound.right]:[0,lowerBound]}(),lowerBound=_ref[0],upperBound=_ref[1]),lowerBound=Math.max(0,parseInt(lowerBound))||0,upperBound=Math.min(array.length-1,parseInt(upperBound))||1/0,array.slice(lowerBound,+upperBound+1||9e9)):[]}}),app.filter("percent",function($filter){return function(num,showZeros,showNegative){return null==showZeros&&(showZeros=!1),null==showNegative&&(showNegative=!1),_.isUndefined(num)||_.isNull(num)?"":(num=(100*parseFloat(num)).toFixed(2),num=$filter("number")(num,2),showZeros||(num=num.replace(".00","")),showNegative||(num=num.replace("-","")),""+num+"%")}}),app.directive("percent",function(){return{restrict:"A",link:function(scope,element,attributes){var $element;return $element=$(element),$element.addClass("percent"),attributes.$observe("percent",function(percent){return percent=parseFloat(percent),$element.addClass(function(){return percent>0?"percent-positive":0>percent?"percent-negative":void 0}()),0!==percent?$element.contents().wrap("<span class='perchevron'></span>"):void 0})}}}),app.directive("focus",function(){return{restrict:"A",link:function(scope,element,attributes){var $element,parse;return $element=$(element),parse=function(x){return"true"===x},attributes.$observe("focus",function(shouldFocus){var method;return shouldFocus=parse(shouldFocus),method=shouldFocus?"focus":"blur",$element[method]()})}}}),app.filter("diff",function($filter){return function(num){return num=(num||"").toString().replace("-",""),$filter("number")(num)}}),app.service("NumberAbbreviator",function(){var abbreviateNumber,enforcePrecision,_defaultDict;return _defaultDict={thousand:"k",million:"m",billion:"b"},enforcePrecision=function(val,nDecimalDigits){var pow;return pow=Math.pow(10,nDecimalDigits),+(Math.round(val*pow)/pow).toFixed(nDecimalDigits)},abbreviateNumber=function(val,nDecimals,dict){var mod,str;return nDecimals=null!=nDecimals?nDecimals:1,dict=dict||_defaultDict,1e3>val?val.toFixed(nDecimals):(val=enforcePrecision(val,nDecimals),str=void 0,mod=void 0,1e6>val?(mod=enforcePrecision(val/1e3,nDecimals),str=1e3>mod?mod+dict.thousand:1+dict.million):1e9>val?(mod=enforcePrecision(val/1e6,nDecimals),str=1e3>mod?mod+dict.million:1+dict.billion):str=enforcePrecision(val/1e9,nDecimals)+dict.billion,str)},{format:abbreviateNumber}}),app.filter("money",function($filter,$rootScope,NumberAbbreviator){return function(text,digits,abbreviate){var currencySymbol,_ref;return null==digits&&(digits=2),null==abbreviate&&(abbreviate=!0),_.isUndefined(text)||_.isNull(text)||_.isNaN(parseFloat(text))?"":(text=function(){var isNegative,_ref;return abbreviate?NumberAbbreviator.format(parseFloat(text),digits):(text=$filter("currency")(parseFloat(text).toFixed(digits)),text=text.replace("$",""),isNegative=/^\([\d|\.|,|\ ]+\)$/.test(text),text=null!=(_ref=text.match(/^\(?([\d|\.|,|\ ]+)\)?$/))?_ref[1]:void 0,isNegative&&(text="−"+text),text.replace(/\.00$/,"").replace(/\.0$/,""))}(),currencySymbol=(null!=(_ref=$rootScope.selectedCurrency)?_ref.symbol:void 0)||"$",""+currencySymbol+text)}}),app.filter("tel",function(){return function(tel){var city,country,number,value;if(!tel)return"";if(value=tel.toString().trim().replace(/^\+/,""),value.match(/[^0-9]/))return tel;switch(country=void 0,city=void 0,number=void 0,value.length){case 10:country=1,city=value.slice(0,3),number=value.slice(3);break;case 11:country=value[0],city=value.slice(1,4),number=value.slice(4);break;case 12:country=value.slice(0,3),city=value.slice(3,5),number=value.slice(5);break;default:return tel}return 1===country&&(country=""),number=number.slice(0,3)+"-"+number.slice(3),(country+" ("+city+") "+number).trim()}})}).call(this);