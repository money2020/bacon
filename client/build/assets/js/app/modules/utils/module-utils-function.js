(function() {
  var __slice = [].slice;

  angular.module('utils.function', []).service('FnUtils', function($timeout, $rootScope) {
    return {
      debounce: function(time, fn) {
        var resetTimer, timerId;
        timerId = null;
        return resetTimer = function() {
          var args, call, _this;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          _this = this;
          call = function() {
            return $rootScope.$apply(function() {
              return fn.apply(_this, args);
            });
          };
          clearTimeout(timerId);
          timerId = setTimeout(call, time);
          return resetTimer;
        };
      }
    };
  });

}).call(this);
