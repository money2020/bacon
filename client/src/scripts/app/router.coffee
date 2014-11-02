
angular.module('42.user-admin.router', [])

.constant "ROUTES",

    '/someroute':
        templateUrl: '/partials/someroute.html'
        controller:  'SomeRouteController'


.config ($routeProvider, $locationProvider, ROUTES) ->

    for path, options of ROUTES
        # options.resolve = resolve if resolve
        $routeProvider.when path, options
