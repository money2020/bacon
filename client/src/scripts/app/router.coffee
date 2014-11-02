
angular.module('money2020.bacon.router', [])


.constant "ROUTES",

    '/':
        templateUrl: '/partials/partial-transactions.html'
        controller:  'TransactionsController'
        resolve:
            State: (TransactionAPI, AppState) ->
                # console.log TransactionAPI
                # console.log AppState
                TransactionAPI.getSketchyTransactions().then (transactions) ->
                    return new AppState(transactions)

    '/verify/fraud':
        templateUrl: '/partials/partial-verify-fraud.html'
        controller:  'VerifyFraudController'

    '/verify/ok':
        templateUrl: '/partials/partial-verify-ok.html'
        controller:  'VerifyOkController'

    '/auth/sms':
        templateUrl: '/partials/partial-auth-sms.html'
        controller:  'AuthSMSController'


.config ($routeProvider, $locationProvider, ROUTES) ->
    for path, options of ROUTES
        $routeProvider.when path, options
