
angular.module('money2020.bacon', [
    'ng'
    'ngRoute'
    'ngAnimate'
    'ajoslin.promise-tracker'

    'utils'
    'money2020.bacon.router'
    'money2020.bacon.transactions'
    'money2020.bacon.auth'
])


# Angular UI configuration
.value('ui.config', {})


.config ($httpProvider) ->
    # This is to prevent angular from removing keys prefixed with `$`,
    # as those are needed for the query api.
    $httpProvider.defaults.transformRequest = [
        (data) -> JSON.stringify(data)
    ]
    # Allows CORS
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']


.run ($rootScope, $route) ->
    $rootScope.route = $route
    $rootScope.modalShown = false

    $rootScope.modal =
        shown:  false
        hide: ->
            @shown = false
        toggle: ->
            @shown = !@shown

    $rootScope.authentications = [
        {
             label: 'SMS Authentication (twilio)'
             description: \
             """
             Calls the user via SMS to verify if the customer is legit.
             """
             checked: true
        }
        {
             label: 'Facebook Authentication'
             description: \
             """
             Look at friends and activity to determine if the customer is a human.
             """
             checked: true
        }
        {
             label: 'Apple Pay'
             description: \
             """
             Use Apples to get indentified. Yum!
             """
             checked: false
        }
    ]
