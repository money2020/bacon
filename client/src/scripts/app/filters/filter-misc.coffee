
app.filter 'removeZerosFromMoney', -> (text) ->
    return text[0..-4]


app.filter 'limit', -> (array, lowerBound, upperBound) ->
    return [] if not array

    if arguments.length is 2
        [lowerBound, upperBound] = do ->
            return [lowerBound.left, lowerBound.right] if _.isObject lowerBound
            return [0, lowerBound]

    lowerBound = Math.max(0,              (parseInt lowerBound)) or 0
    upperBound = Math.min(array.length-1, (parseInt upperBound)) or Infinity

    return array[lowerBound..upperBound]


app.filter 'percent', ($filter) -> (num, showZeros = false, showNegative = false) ->
    return '' if _.isUndefined(num) or _.isNull(num)
    num = (parseFloat(num) * 100).toFixed(2)
    num = $filter('number')(num, 2)
    num = num.replace('.00', '') if not showZeros
    num = num.replace('-', '') if not showNegative
    return "#{num}%"


app.directive 'percent', ->
    restrict: 'A'
    link: (scope, element, attributes) ->
        $element = $(element)
        $element.addClass 'percent'
        attributes.$observe 'percent', (percent) ->
            percent = parseFloat(percent)
            $element.addClass do ->
                return 'percent-positive' if percent > 0
                return 'percent-negative' if percent < 0
            if percent isnt 0
                $element.contents().wrap("<span class='perchevron'></span>")


app.directive 'focus', ->
    restrict: 'A'
    link: (scope, element, attributes) ->
        $element = $(element)
        parse = (x) -> x is 'true'
        attributes.$observe 'focus', (shouldFocus) ->
            shouldFocus = parse(shouldFocus)
            method = if shouldFocus then 'focus' else 'blur'
            $element[method]()


app.filter 'diff', ($filter) -> (num) ->
    num = (num or '').toString().replace('-', '')
    $filter('number')(num)


app.service 'NumberAbbreviator', ->

    # Taken from:
    # https://github.com/mout/mout/tree/v0.3.0/src/number

    _defaultDict =
        thousand: 'k'
        million:  'm'
        billion:  'b'

    enforcePrecision = (val, nDecimalDigits) ->
        pow = Math.pow(10, nDecimalDigits)
        return +(Math.round(val * pow) / pow).toFixed(nDecimalDigits)

    abbreviateNumber = (val, nDecimals, dict) ->
        nDecimals = (if nDecimals? then nDecimals else 1)
        dict = dict or _defaultDict
        return val.toFixed(nDecimals) if val < 1000
        val = enforcePrecision(val, nDecimals)
        str = undefined
        mod = undefined
        if val < 1000000
            mod = enforcePrecision(val / 1000, nDecimals)
            # might overflow to next scale during rounding
            str = (if mod < 1000 then mod + dict.thousand else 1 + dict.million)
        else if val < 1000000000
            mod = enforcePrecision(val / 1000000, nDecimals)
            str = (if mod < 1000 then mod + dict.million else 1 + dict.billion)
        else
            str = enforcePrecision(val / 1000000000, nDecimals) + dict.billion
        return str

    return format:abbreviateNumber


app.filter 'money', ($filter, $rootScope, NumberAbbreviator) -> (text, digits = 2, abbreviate = true) ->
    return '' if _.isUndefined(text) or _.isNull(text) or _.isNaN(parseFloat(text))
    text = do ->
        return NumberAbbreviator.format(parseFloat(text), digits) if abbreviate
        text = $filter('currency')(parseFloat(text).toFixed(digits))
        text = text.replace('$', '')
        isNegative = /^\([\d|\.|,|\ ]+\)$/.test(text)
        text = text.match(/^\(?([\d|\.|,|\ ]+)\)?$/)?[1]
        text = '−' + text if isNegative
        return text.replace(/\.00$/, '').replace(/\.0$/, '')
    currencySymbol = $rootScope.selectedCurrency?.symbol or '$'
    return "#{currencySymbol}#{text}"


app.filter "tel", ->
  (tel) ->
    return ""  unless tel
    value = tel.toString().trim().replace(/^\+/, "")
    return tel  if value.match(/[^0-9]/)
    country = undefined
    city = undefined
    number = undefined
    switch value.length
      when 10 # +1PPP####### -> C (PPP) ###-####
        country = 1
        city = value.slice(0, 3)
        number = value.slice(3)
      when 11 # +CPPP####### -> CCC (PP) ###-####
        country = value[0]
        city = value.slice(1, 4)
        number = value.slice(4)
      when 12 # +CCCPP####### -> CCC (PP) ###-####
        country = value.slice(0, 3)
        city = value.slice(3, 5)
        number = value.slice(5)
      else
        return tel
    country = ""  if country is 1
    number = number.slice(0, 3) + "-" + number.slice(3)
    (country + " (" + city + ") " + number).trim()
