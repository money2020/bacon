(function(){angular.module("utils.object",[]).service("ObjectUtils",function(){var flattenObject,objectMap;return flattenObject=function(object,_arg,result,prefix,depth){var key,maxDepth,separator,value,_ref;if(_ref=null!=_arg?_arg:{},separator=_ref.separator,maxDepth=_ref.maxDepth,null==result&&(result={}),null==prefix&&(prefix=""),null==depth&&(depth=0),"number"!=typeof maxDepth&&(maxDepth=Number.POSITIVE_INFINITY),null==separator&&(separator=""),null===object)return object;Object.keys(object).forEach(function(key){var invalid;if(invalid=-1!==key.indexOf(separator))throw new Error("Key `"+key+"` contains separator `"+separator+"`")});for(key in object)value=object[key],angular.isObject(value)&&maxDepth>depth?flattenObject(value,{separator:separator,maxDepth:maxDepth},result,""+prefix+key+separator,depth+1):result[""+prefix+key]=value;return result},objectMap=function(result,object,fn){var key,value;object=fn(object);for(key in object)value=object[key],angular.isObject(value)&&(result[key]=objectMap({},value,fn));return result},{flatten:flattenObject,isEmpty:function(object){return 0===Object.keys(object||{}).length},query:function(object,key,separator){var current,token,tokens,_i,_len;for(null==separator&&(separator="."),tokens=key.split(separator),current=void 0,_i=0,_len=tokens.length;_len>_i;_i++)if(token=tokens[_i],current=(current||object)[token],void 0===current)return void 0;return current},objectMap:function(object,fn){return objectMap({},object,fn)},hash:function(){var defaultHashFn;return defaultHashFn=function(x){return x},function(object,hashFn){if(null==hashFn&&(hashFn=defaultHashFn),!object)throw new Error("`object` argument is required.");return object=flattenObject(object),object=Object.keys(object).sort().reduce(function(result,key){return result.concat([[key,object[key]]])},[]),hashFn(JSON.stringify(object))}}()}})}).call(this);