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
    clean = callerLine.slice(index+2, callerLine.length).split(':')[2]

    errorMessage = "#{clean}: Test failed"
    errorMessage += ": #{message}" if message

    console.error errorMessage
    console.log ''

