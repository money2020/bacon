(function() {
  angular.module('money2020.bacon.auth', []).constant('SMS_STATUSES', {
    OK: 'ok',
    FRAUD: 'fraud',
    UNVERIFIED: 'unverified'
  }).service('AuthAPI', function($http, SUCCESS_URL, SMS_STATUSES) {
    return {
      getSMSStatus: function() {
        return $http.get('/auth/SMSAuth/status');
      }
    };
  }).controller('AuthSMSController', function($timeout, AuthAPI, SMS_STATUSES) {
    var checkStatus;
    checkStatus = function() {
      return AuthAPI.getSMSStatus().then(function(status) {
        if (status === SMS_STATUSES.FRAUD) {
          return location.path('/#/verify/fraud');
        }
        if (status === SMS_STATUSES.OK) {
          return location.path('/#/verify/ok');
        }
        return $timeout(checkStatus, 0);
      });
    };
    return checkStatus();
  });

}).call(this);
