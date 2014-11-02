

angular.module('utils', [
    'utils.function'
    'utils.object'
])


.service 'Utils', (FnUtils, ObjectUtils, $timeout) ->

    sum = (list, fn) ->
        fn = ((x) -> x) if not fn
        _.reduce list, ((result, x) -> result + fn(x)), 0


    average = (list, fn) ->
        return 0 if list.length is 0
        (sum list, fn) / list.length


    mapRange = (times, fn) ->
        _.map (_.range times), fn


    clamp = (min, x, max) ->
        Math.min (Math.max x, min), max


    copy = (object) ->
        angular.copy object
        # JSON.parse JSON.stringify object


    chunk = (array, size) ->
        result = []
        while array.length
            result.push array.splice 0, size
        return result

    rejectDuplicateModels = (collection) ->
        seen = {}
        collection.filter (model) ->
            (not seen[model.id]) and (seen[model.id] = true)

    rotate = (sourceIndex, targetIndex, array) ->
        [targetIndex, array] = [array.length-1, array]             if (_.isUndefined targetIndex) and (_.isArray array)
        [targetIndex, array] = [targetIndex.length-1, targetIndex] if (_.isArray targetIndex)
        beforeSource = array[0..sourceIndex]
        afterSource  = array[sourceIndex+1..-1]
        return afterSource.concat beforeSource

    timeIt = (label, fn) ->
        console.time label
        result = fn()
        console.timeEnd label
        return result

    promiseTimer = (label) -> (promise) ->
        label = "[timer] #{label}"
        console.time(label)
        promise.then (result) ->
            console.timeEnd(label)
            return result

    dateRange = (min, max, bucket) ->
        console.log 'minmax:', min, max
        result = []
        moment().range(min, max).by bucket, (date) ->
            result.push date
        result.push max
        return result[0..-2]


    uuid = do ->
        s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
        -> s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()


    return {
        sum
        rotate
        copy
        chunk
        mapRange
        rejectDuplicateModels
        uniqueModels: rejectDuplicateModels
        timeIt
        average
        clamp
        promiseTimer
        dateRange
        object: ObjectUtils
        function: FnUtils
        uuid: uuid
    }


