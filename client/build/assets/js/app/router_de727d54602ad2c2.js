(function(){angular.module("money2020.bacon.router",[]).constant("ROUTES",{"/":{templateUrl:"/partials/partial-transactions.html",controller:"TransactionsController",resolve:{State:function(TransactionAPI,AppState){return TransactionAPI.getSketchyTransactions().then(function(transactions){return new AppState(transactions)})}}},"/verify/fraud":{templateUrl:"/partials/partial-verify-fraud.html",controller:"VerifyFraudController"},"/verify/ok":{templateUrl:"/partials/partial-verify-ok.html",controller:"VerifyOkController"},"/auth/sms":{templateUrl:"/partials/partial-auth-sms.html",controller:"AuthSMSController"}}).config(function($routeProvider,$locationProvider,ROUTES){var options,path,_results;_results=[];for(path in ROUTES)options=ROUTES[path],_results.push($routeProvider.when(path,options));return _results})}).call(this);