
angular.module('utils.object', [])

.service 'ObjectUtils', ->

    flattenObject = (object, {separator, maxDepth} = {}, result = {}, prefix = '', depth = 0) ->
        maxDepth   = Number.POSITIVE_INFINITY if not (typeof maxDepth is 'number')
        separator ?= ''

        return object if object is null

        Object.keys(object).forEach (key) ->
            invalid = key.indexOf(separator) isnt -1
            throw new Error("Key `#{key}` contains separator `#{separator}`") if invalid

        for key, value of object
            if angular.isObject(value) and depth < maxDepth
                flattenObject(value, {separator, maxDepth}, result, "#{prefix}#{key}#{separator}", depth+1)
            else
                result["#{prefix}#{key}"] = value

        return result

    objectMap = (result, object, fn) ->
        object = fn(object)
        for key, value of object
            result[key] = objectMap({}, value, fn) if angular.isObject(value)
        return result


    flatten: flattenObject

    isEmpty: (object) ->
        Object.keys(object or {}).length is 0

    query: (object, key, separator) ->
        separator ?= '.'
        tokens = key.split(separator)
        current = undefined
        for token in tokens
            current = (current or object)[token]
            return undefined if current is undefined
        return current

    objectMap: (object, fn) ->
        objectMap({}, object, fn)

    hash: do ->
        defaultHashFn = (x) -> return x
        (object, hashFn = defaultHashFn) ->
            throw new Error("`object` argument is required.") if not object
            object = flattenObject(object)
            object = Object.keys(object).sort().reduce ((result, key) ->
                result.concat [[key, object[key]]]
            ), []
            return hashFn(JSON.stringify(object))
