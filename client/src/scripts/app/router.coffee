
angular.module('money2020.bacon.router', [])


.constant "ROUTES",

    '/':
        templateUrl: '/partials/partial-transactions.html'
        controller:  'TransactionsController'
        resolve:
            State: (TransactionAPI, AppState) -> TransactionAPI.getState().then (state) -> new AppState(state)

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
