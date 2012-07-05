class window.Test

    constructor: ->

        @_runTests()

    show: (value, message) ->

        console.log message if message
        console.log value

    assert: (bool, message) ->

        return if bool

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

    equals: (value1, value2) ->

        type1 = @_typeOf value1
        type2 = @_typeOf value2

        return false if type1 isnt type2

        if type1 is 'object' and type2 is 'object'
            return console.warn 'Object comparison not implemented yet'

        if type1 is 'array' and type2 is 'array'
            return @_equalArrays value1, value2

        value1 is value2


    # Changes string like 'testCamelCase' to 'Camel Case'
    _formatTestName: (name) ->

        name = name.substring 4 if name.substring(0, 4) is 'test'
        name = name.replace /([A-Z])/g, (match, group1) -> " #{group1}"
        name.substring 1

    _typeOf: (value) ->

        type = typeof value
        if type is 'object'
            return 'null' unless value
            type = 'array' if value instanceof Array
        type

    _equalArrays: (array1, array2) ->

        return unless array1.length is array2.length

        for elem, index in array1
            return false unless @equals elem, array2[index]

        true

    _runTests: =>

        for prop of @
            if prop.substring(0, 4) is 'test' and typeof @[prop] is 'function'
                console.warn "Running test: #{@_formatTestName prop}"
                @.before?()
                @[prop]()
                @.after?()
                console.log ''
