(function() {
  angular.module('money2020.bacon.transactions', []).controller('TransactionsController', function($scope, $timeout, TransactionAPI, State) {
    var addFraud, addGood, updateState;
    console.log("Transaction Controller Initialized");
    $scope.State = State;
    State.add({
      id: 'sketchysms01',
      score: 0.5,
      state: {
        id: 'sms',
        label: 'Sketchy SMS'
      }
    });
    addGood = function() {
      return State.add({
        id: 'good' + Math.random(),
        score: 0.5,
        state: {
          id: 'ok',
          label: 'Good'
        },
        data: {
          name: chance.name()
        }
      }, $timeout(addGood, Math.random() * 1000));
    };
    addFraud = function() {
      return State.add({
        id: 'fraud' + Math.random(),
        score: 0.5,
        state: {
          id: 'fraud',
          label: 'Fraud',
          icon: 'close'
        },
        data: {
          name: chance.name()
        }
      }, $timeout(addFraud, Math.random() * 5000));
    };
    $timeout(addGood, 0);
    $timeout(addFraud, 0);
    updateState = function() {
      console.log('getting sketchy transactions');
      return TransactionAPI.getSketchyTransactions().then(function(transactions) {
        State.updateSketchy(transactions);
        return $timeout(updateState, 0);
      });
    };
    return updateState();
  }).constant('TransactionStates', {
    'ok': 'ok',
    'fraud': 'fraud'
  }).service('TransactionAPI', function($q, $http) {
    var getRaw;
    getRaw = function() {
      return $http.get('/auth/SMSAuth/status2').then(function(data) {
        if (!data || !data.data) {
          return [];
        }
        data = data.filter(function(x) {
          var _ref;
          return !((_ref = x.status) === "fraud" || _ref === "ok");
        });
        return data;
      });
    };
    return {
      getSketchyTransactions: function() {
        return getRaw().then(function(data) {
          return {
            stats: {},
            label: 'Sketchy Transactions',
            transactions: _.indexBy(data.data, 'id')
          };
        });
      }
    };
  }).factory('AppState', function($timeout, TransactionStates) {
    return function(state) {
      var initState, update;
      initState = function() {
        var result;
        result = {};
        result.sketchy = {};
        result.ok = {
          label: 'ok',
          icon: 'check',
          stats: {},
          transactions: {}
        };
        result.fraud = {
          label: 'fraud',
          icon: 'cross',
          stats: {},
          transactions: {}
        };
        return result;
      };
      update = function(newState) {
        newState = JSON.parse(JSON.stringify(newState));
        if (state == null) {
          state = {};
        }
        state.sketchy = newState.sketchy;
        state.ok = {
          label: 'ok',
          icon: 'check',
          stats: {},
          transactions: {}
        };
        return state.fraud = {
          label: 'fraud',
          icon: 'cross',
          stats: {},
          transactions: {}
        };
      };
      if (!state) {
        update(initState());
      }
      return {
        getState: function() {
          return state;
        },
        updateSketchy: function(sketchy) {
          $timeout((function() {
            return console.log(state);
          }), 0);
          return update({
            sketchy: sketchy
          });
        },
        add: function(transaction) {
          var isTransient, label, _base, _base1, _base2, _base3, _name, _ref,
            _this = this;
          isTransient = (_ref = transaction.state.id) === TransactionStates.ok || _ref === TransactionStates.fraud;
          if (isTransient) {
            if (state[_name = transaction.state.id] == null) {
              state[_name] = {
                stats: {},
                transactions: {}
              };
            }
            if ((_base = state[transaction.state.id].stats).count == null) {
              _base.count = 0;
            }
            state[transaction.state.id].stats.count++;
            state[transaction.state.id].transactions[transaction.id] = transaction;
            return $timeout((function() {
              return _this.del(transaction);
            }), 1800);
          } else {
            label = transaction.state.label;
            if (state.sketchy == null) {
              state.sketchy = {
                label: label,
                stats: {},
                transactions: {}
              };
            }
            if ((_base1 = state.sketchy).stats == null) {
              _base1.stats = {};
            }
            if ((_base2 = state.sketchy.stats).count == null) {
              _base2.count = 0;
            }
            state.sketchy.stats.count++;
            if ((_base3 = state.sketchy).transactions == null) {
              _base3.transactions = {};
            }
            return state.sketchy.transactions[transaction.id] = transaction;
          }
        },
        del: function(transaction) {
          var collection, isTransient, _ref;
          isTransient = (_ref = transaction.state.id) === TransactionStates.ok || _ref === TransactionStates.fraud;
          collection = (function() {
            if (isTransient) {
              return state[transaction.state.id];
            }
            return state.sketchy;
          })();
          return delete collection.transactions[transaction.id];
        }
      };
    };
  }).directive('transactions', function() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/widgets/widget-transactions.html',
      link: function(scope) {
        return scope.state = scope.State.getState();
      }
    };
  }).directive('transactionList', function() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/widgets/widget-transaction-list.html',
      scope: {
        state: '=',
        animate: '='
      }
    };
  }).directive('transactionListSketchy', function() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/widgets/widget-transaction-list-sketchy.html',
      scope: {
        state: '=',
        animate: '='
      }
    };
  }).directive('transactionListItem', function($timeout) {
    return {
      restrict: 'C',
      link: function(scope, element) {
        var $el;
        console.log('sup');
        $el = $(element);
        return $timeout((function() {
          var velocity;
          if (!$el.hasClass('fallanimation')) {
            return;
          }
          velocity = Math.random() * (10 - 6) + 6;
          return $timeout((function() {
            return $el.box2d({
              'y-velocity': velocity
            });
          }), 0);
        }), 0);
      }
    };
  });

}).call(this);
