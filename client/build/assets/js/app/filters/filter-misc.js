(function() {
  app.filter('removeZerosFromMoney', function() {
    return function(text) {
      return text.slice(0, -3);
    };
  });

  app.filter('limit', function() {
    return function(array, lowerBound, upperBound) {
      var _ref;
      if (!array) {
        return [];
      }
      if (arguments.length === 2) {
        _ref = (function() {
          if (_.isObject(lowerBound)) {
            return [lowerBound.left, lowerBound.right];
          }
          return [0, lowerBound];
        })(), lowerBound = _ref[0], upperBound = _ref[1];
      }
      lowerBound = Math.max(0, parseInt(lowerBound)) || 0;
      upperBound = Math.min(array.length - 1, parseInt(upperBound)) || Infinity;
      return array.slice(lowerBound, +upperBound + 1 || 9e9);
    };
  });

  app.filter('percent', function($filter) {
    return function(num, showZeros, showNegative) {
      if (showZeros == null) {
        showZeros = false;
      }
      if (showNegative == null) {
        showNegative = false;
      }
      if (_.isUndefined(num) || _.isNull(num)) {
        return '';
      }
      num = (parseFloat(num) * 100).toFixed(2);
      num = $filter('number')(num, 2);
      if (!showZeros) {
        num = num.replace('.00', '');
      }
      if (!showNegative) {
        num = num.replace('-', '');
      }
      return "" + num + "%";
    };
  });

  app.directive('percent', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attributes) {
        var $element;
        $element = $(element);
        $element.addClass('percent');
        return attributes.$observe('percent', function(percent) {
          percent = parseFloat(percent);
          $element.addClass((function() {
            if (percent > 0) {
              return 'percent-positive';
            }
            if (percent < 0) {
              return 'percent-negative';
            }
          })());
          if (percent !== 0) {
            return $element.contents().wrap("<span class='perchevron'></span>");
          }
        });
      }
    };
  });

  app.directive('focus', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attributes) {
        var $element, parse;
        $element = $(element);
        parse = function(x) {
          return x === 'true';
        };
        return attributes.$observe('focus', function(shouldFocus) {
          var method;
          shouldFocus = parse(shouldFocus);
          method = shouldFocus ? 'focus' : 'blur';
          return $element[method]();
        });
      }
    };
  });

  app.filter('diff', function($filter) {
    return function(num) {
      num = (num || '').toString().replace('-', '');
      return $filter('number')(num);
    };
  });

  app.service('NumberAbbreviator', function() {
    var abbreviateNumber, enforcePrecision, _defaultDict;
    _defaultDict = {
      thousand: 'k',
      million: 'm',
      billion: 'b'
    };
    enforcePrecision = function(val, nDecimalDigits) {
      var pow;
      pow = Math.pow(10, nDecimalDigits);
      return +(Math.round(val * pow) / pow).toFixed(nDecimalDigits);
    };
    abbreviateNumber = function(val, nDecimals, dict) {
      var mod, str;
      nDecimals = (nDecimals != null ? nDecimals : 1);
      dict = dict || _defaultDict;
      if (val < 1000) {
        return val.toFixed(nDecimals);
      }
      val = enforcePrecision(val, nDecimals);
      str = void 0;
      mod = void 0;
      if (val < 1000000) {
        mod = enforcePrecision(val / 1000, nDecimals);
        str = (mod < 1000 ? mod + dict.thousand : 1 + dict.million);
      } else if (val < 1000000000) {
        mod = enforcePrecision(val / 1000000, nDecimals);
        str = (mod < 1000 ? mod + dict.million : 1 + dict.billion);
      } else {
        str = enforcePrecision(val / 1000000000, nDecimals) + dict.billion;
      }
      return str;
    };
    return {
      format: abbreviateNumber
    };
  });

  app.filter('money', function($filter, $rootScope, NumberAbbreviator) {
    return function(text, digits, abbreviate) {
      var currencySymbol, _ref;
      if (digits == null) {
        digits = 2;
      }
      if (abbreviate == null) {
        abbreviate = true;
      }
      if (_.isUndefined(text) || _.isNull(text) || _.isNaN(parseFloat(text))) {
        return '';
      }
      text = (function() {
        var isNegative, _ref;
        if (abbreviate) {
          return NumberAbbreviator.format(parseFloat(text), digits);
        }
        text = $filter('currency')(parseFloat(text).toFixed(digits));
        text = text.replace('$', '');
        isNegative = /^\([\d|\.|,|\ ]+\)$/.test(text);
        text = (_ref = text.match(/^\(?([\d|\.|,|\ ]+)\)?$/)) != null ? _ref[1] : void 0;
        if (isNegative) {
          text = '−' + text;
        }
        return text.replace(/\.00$/, '').replace(/\.0$/, '');
      })();
      currencySymbol = ((_ref = $rootScope.selectedCurrency) != null ? _ref.symbol : void 0) || '$';
      return "" + currencySymbol + text;
    };
  });

  app.filter("tel", function() {
    return function(tel) {
      var city, country, number, value;
      if (!tel) {
        return "";
      }
      value = tel.toString().trim().replace(/^\+/, "");
      if (value.match(/[^0-9]/)) {
        return tel;
      }
      country = void 0;
      city = void 0;
      number = void 0;
      switch (value.length) {
        case 10:
          country = 1;
          city = value.slice(0, 3);
          number = value.slice(3);
          break;
        case 11:
          country = value[0];
          city = value.slice(1, 4);
          number = value.slice(4);
          break;
        case 12:
          country = value.slice(0, 3);
          city = value.slice(3, 5);
          number = value.slice(5);
          break;
        default:
          return tel;
      }
      if (country === 1) {
        country = "";
      }
      number = number.slice(0, 3) + "-" + number.slice(3);
      return (country + " (" + city + ") " + number).trim();
    };
  });

}).call(this);
