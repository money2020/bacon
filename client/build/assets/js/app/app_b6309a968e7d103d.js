(function(){angular.module("money2020.bacon",["ng","ngRoute","ngAnimate","ajoslin.promise-tracker","utils","money2020.bacon.router","money2020.bacon.transactions","money2020.bacon.auth"]).value("ui.config",{}).config(function($httpProvider){return $httpProvider.defaults.transformRequest=[function(data){return JSON.stringify(data)}],$httpProvider.defaults.useXDomain=!0,delete $httpProvider.defaults.headers.common["X-Requested-With"]}).run(function($rootScope,$route){return $rootScope.route=$route,$rootScope.modalShown=!1,$rootScope.modal={shown:!1,hide:function(){return this.shown=!1},toggle:function(){return this.shown=!this.shown}},$rootScope.authentications=[{label:"SMS Authentication (twilio)",description:"Calls the user via SMS to verify if the customer is legit.",checked:!0},{label:"Facebook Authentication",description:"Look at friends and activity to determine if the customer is a human.",checked:!0},{label:"Apple Pay",description:"Use Apples to get indentified. Yum!",checked:!1}]})}).call(this);