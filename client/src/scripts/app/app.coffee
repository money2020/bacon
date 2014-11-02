
angular.module('money2020.bacon', [
    'ng'
    'ngRoute'
    'ajoslin.promise-tracker'

    'utils'
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


.run ($log) ->
