

angular.module('money2020.bacon.auth', [])


.constant('SUCCESS_URL', "/#/succes")


.service 'AuthAPI', ($http, SUCCESS_URL) ->

    getSMSStatus: ->


