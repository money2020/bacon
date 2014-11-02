

angular.module('money2020.bacon.auth', [])


.constant('SMS_STATUSES', {OK:'ok', FRAUD:'fraud', UNVERIFIED:'unverified'})


.service 'AuthAPI', ($http, SUCCESS_URL, SMS_STATUSES) ->

    getSMSStatus: ->
        $http.get('/auth/SMSAuth/status')


.controller 'AuthSMSController', ($timeout, AuthAPI, SMS_STATUSES) ->

    checkStatus = ->
        AuthAPI.getSMSStatus().then (status) ->
            return location.path('/#/verify/fraud') if status is SMS_STATUSES.FRAUD
            return location.path('/#/verify/ok')    if status is SMS_STATUSES.OK
            $timeout checkStatus, 0

    checkStatus()

