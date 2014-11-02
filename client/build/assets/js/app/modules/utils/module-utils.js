(function() {
  angular.module('utils', ['utils.function', 'utils.object']).service('Utils', function(FnUtils, ObjectUtils, $timeout) {
    var average, chunk, clamp, copy, dateRange, mapRange, promiseTimer, randomInt, rejectDuplicateModels, rotate, sum, timeIt, uuid;
    sum = function(list, fn) {
      if (!fn) {
        fn = (function(x) {
          return x;
        });
      }
      return _.reduce(list, (function(result, x) {
        return result + fn(x);
      }), 0);
    };
    average = function(list, fn) {
      if (list.length === 0) {
        return 0;
      }
      return (sum(list, fn)) / list.length;
    };
    mapRange = function(times, fn) {
      return _.map(_.range(times), fn);
    };
    clamp = function(min, x, max) {
      return Math.min(Math.max(x, min), max);
    };
    copy = function(object) {
      return angular.copy(object);
    };
    randomInt = function(min, max) {
      return Math.random() * (max - min) + min;
    };
    chunk = function(array, size) {
      var result;
      result = [];
      while (array.length) {
        result.push(array.splice(0, size));
      }
      return result;
    };
    rejectDuplicateModels = function(collection) {
      var seen;
      seen = {};
      return collection.filter(function(model) {
        return (!seen[model.id]) && (seen[model.id] = true);
      });
    };
    rotate = function(sourceIndex, targetIndex, array) {
      var afterSource, beforeSource, _ref, _ref1;
      if ((_.isUndefined(targetIndex)) && (_.isArray(array))) {
        _ref = [array.length - 1, array], targetIndex = _ref[0], array = _ref[1];
      }
      if (_.isArray(targetIndex)) {
        _ref1 = [targetIndex.length - 1, targetIndex], targetIndex = _ref1[0], array = _ref1[1];
      }
      beforeSource = array.slice(0, +sourceIndex + 1 || 9e9);
      afterSource = array.slice(sourceIndex + 1);
      return afterSource.concat(beforeSource);
    };
    timeIt = function(label, fn) {
      var result;
      console.time(label);
      result = fn();
      console.timeEnd(label);
      return result;
    };
    promiseTimer = function(label) {
      return function(promise) {
        label = "[timer] " + label;
        console.time(label);
        return promise.then(function(result) {
          console.timeEnd(label);
          return result;
        });
      };
    };
    dateRange = function(min, max, bucket) {
      var result;
      console.log('minmax:', min, max);
      result = [];
      moment().range(min, max).by(bucket, function(date) {
        return result.push(date);
      });
      result.push(max);
      return result.slice(0, -1);
    };
    uuid = (function() {
      var s4;
      s4 = function() {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
      };
      return function() {
        return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
      };
    })();
    return {
      sum: sum,
      rotate: rotate,
      copy: copy,
      chunk: chunk,
      mapRange: mapRange,
      rejectDuplicateModels: rejectDuplicateModels,
      uniqueModels: rejectDuplicateModels,
      timeIt: timeIt,
      average: average,
      clamp: clamp,
      promiseTimer: promiseTimer,
      dateRange: dateRange,
      randomInt: randomInt,
      object: ObjectUtils,
      "function": FnUtils,
      uuid: uuid
    };
  });

}).call(this);
