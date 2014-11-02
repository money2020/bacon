

angular.module('utils.function', [])

.service 'FnUtils', ($timeout, $rootScope) ->

    debounce: (time, fn) ->
        timerId = null
        return resetTimer = (args...) ->
            _this = this
            call = ->
                $rootScope.$apply -> fn.apply(_this, args)
            clearTimeout(timerId)
            timerId = setTimeout call, time
            return resetTimer
