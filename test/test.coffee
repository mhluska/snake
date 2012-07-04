window.show = (variable, message) ->

    console.log message if message
    console.log variable
    console.log ''

window.assert = (exp, message) ->

    return if exp

    # TODO: Make getting the error line number more cross-browser friendly
    getErrorObject = ->
        try
            throw Error('')
        catch err
            return err

    err = getErrorObject()
    callerLine = err.stack.split('\n')[4]
    index = callerLine.indexOf("at ")
    clean = callerLine.slice(index + 2, callerLine.length).split(':')[2]

    errorMessage = "#{clean}: Test failed"
    errorMessage += ": #{message}" if message

    console.error errorMessage
    console.log ''

window.equals = (val1, val2) ->

    type1 = typeOf val1
    type2 = typeOf val2

    return false if type1 isnt type2

    if type1 is 'object' and type2 is 'object'
        return console.warn 'Object comparison not implemented yet'

    return equalArrays val1, val2 if type1 is 'array' and type2 is 'array'

    val1 is val2

typeOf = (value) ->
    type = typeof value
    if type is 'object'
        return 'null' unless value
        type = 'array' if value instanceof Array
    type

equalArrays = (array1, array2) ->

    return unless array1.length is array2.length

    for elem, index in array1
        return false unless equals elem, array2[index]

    true
