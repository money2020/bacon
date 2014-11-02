(function() {
  angular.module('money2020.bacon', ['ng', 'ngRoute', 'ngAnimate', 'ajoslin.promise-tracker', 'utils', 'money2020.bacon.router', 'money2020.bacon.transactions', 'money2020.bacon.auth']).value('ui.config', {}).config(function($httpProvider) {
    $httpProvider.defaults.transformRequest = [
      function(data) {
        return JSON.stringify(data);
      }
    ];
    $httpProvider.defaults.useXDomain = true;
    return delete $httpProvider.defaults.headers.common['X-Requested-With'];
  }).run(function($rootScope, $route) {
    $rootScope.route = $route;
    $rootScope.modalShown = false;
    $rootScope.modal = {
      shown: false,
      hide: function() {
        return this.shown = false;
      },
      toggle: function() {
        return this.shown = !this.shown;
      }
    };
    return $rootScope.authentications = [
      {
        label: 'SMS Authentication (twilio)',
        description: "Calls the user via SMS to verify if the customer is legit.",
        checked: true
      }, {
        label: 'Facebook Authentication',
        description: "Look at friends and activity to determine if the customer is a human.",
        checked: true
      }
    ];
  });

}).call(this);
