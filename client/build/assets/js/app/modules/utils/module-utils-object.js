(function() {
  angular.module('utils.object', []).service('ObjectUtils', function() {
    var flattenObject, objectMap;
    flattenObject = function(object, _arg, result, prefix, depth) {
      var key, maxDepth, separator, value, _ref;
      _ref = _arg != null ? _arg : {}, separator = _ref.separator, maxDepth = _ref.maxDepth;
      if (result == null) {
        result = {};
      }
      if (prefix == null) {
        prefix = '';
      }
      if (depth == null) {
        depth = 0;
      }
      if (!(typeof maxDepth === 'number')) {
        maxDepth = Number.POSITIVE_INFINITY;
      }
      if (separator == null) {
        separator = '';
      }
      if (object === null) {
        return object;
      }
      Object.keys(object).forEach(function(key) {
        var invalid;
        invalid = key.indexOf(separator) !== -1;
        if (invalid) {
          throw new Error("Key `" + key + "` contains separator `" + separator + "`");
        }
      });
      for (key in object) {
        value = object[key];
        if (angular.isObject(value) && depth < maxDepth) {
          flattenObject(value, {
            separator: separator,
            maxDepth: maxDepth
          }, result, "" + prefix + key + separator, depth + 1);
        } else {
          result["" + prefix + key] = value;
        }
      }
      return result;
    };
    objectMap = function(result, object, fn) {
      var key, value;
      object = fn(object);
      for (key in object) {
        value = object[key];
        if (angular.isObject(value)) {
          result[key] = objectMap({}, value, fn);
        }
      }
      return result;
    };
    return {
      flatten: flattenObject,
      isEmpty: function(object) {
        return Object.keys(object || {}).length === 0;
      },
      query: function(object, key, separator) {
        var current, token, tokens, _i, _len;
        if (separator == null) {
          separator = '.';
        }
        tokens = key.split(separator);
        current = void 0;
        for (_i = 0, _len = tokens.length; _i < _len; _i++) {
          token = tokens[_i];
          current = (current || object)[token];
          if (current === void 0) {
            return void 0;
          }
        }
        return current;
      },
      objectMap: function(object, fn) {
        return objectMap({}, object, fn);
      },
      hash: (function() {
        var defaultHashFn;
        defaultHashFn = function(x) {
          return x;
        };
        return function(object, hashFn) {
          if (hashFn == null) {
            hashFn = defaultHashFn;
          }
          if (!object) {
            throw new Error("`object` argument is required.");
          }
          object = flattenObject(object);
          object = Object.keys(object).sort().reduce((function(result, key) {
            return result.concat([[key, object[key]]]);
          }), []);
          return hashFn(JSON.stringify(object));
        };
      })()
    };
  });

}).call(this);
