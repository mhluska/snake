class window.Test

    constructor: ->

        # Backwards compatability for Object.getPrototypeOf
        # Source: http://ejohn.org/blog/objectgetprototypeof/
        if typeof Object.getPrototypeOf isnt 'function'
            if typeof 'test'.__proto__ is 'object'
                Object.getPrototypeOf = (object) ->
                    return object.__proto__
            else
                Object.getPrototypeOf = (object) ->
                    # May break if the constructor has been tampered with
                    return object.constructor.prototype

        @_outputBuffer = []

        # Class accessor. Kind of like '@@' in Ruby
        @.class = (Object.getPrototypeOf @).constructor

        @_origBefore = @before
        @_origAfter = @after

        @_runTests()

    # @before and @after can be overriden with asynchronous initialization. It
    # must execute the start callback once the initialization finishes.
    @before: (start) -> start()

    @after: (start) -> start()

    show: (value, message) ->

        return unless arguments.length > 0

        @_writeMessage message if message
        console.log message if message
        @_writeMessage value
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

        @_writeError errorMessage
        console.error errorMessage

    equals: (value1, value2) ->

        type1 = @_typeOf value1
        type2 = @_typeOf value2

        return false if type1 isnt type2

        if type1 is 'object' and type2 is 'object'
            return @_equalObjects value1, value2

        if type1 is 'array' and type2 is 'array'
            return @_equalArrays value1, value2

        value1 is value2

    # Changes string like 'testCamelCase' to 'Camel Case'
    _formatTestName: (name) ->

        name = name.substring 4 if name.substring(0, 4).toLowerCase() is 'test'
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

    # Source: http://stackoverflow.com/a/1144249/659910 
    _equalObjects: (obj1, obj2) ->

      for prop of obj1
          return false if typeof obj2[prop] is 'undefined'

      for prop of obj1
          if obj1[prop]
              switch typeof obj1[prop]

                  when 'object'
                      return false unless @_equalObjects obj1[prop], obj2[prop]

                  when 'function'
                      return false if typeof obj2[prop] is 'undefined'
                      return false if obj1[prop] isnt obj2[prop]
                  else
                      return false if obj1[prop] isnt obj2[prop]

          else if obj2[prop]
              return false

      for prop of obj2
          return false if typeof obj1[prop] is 'undefined'

      true

    _runTests: =>

        return unless @_formatTestName @.class.name

        @.class.before =>

            @_writeModuleName "Testing module: #{@_formatTestName @.class.name}"
            console.warn "Testing module: #{@_formatTestName @.class.name}"
            console.log ''

            for prop of @
                if prop.substring(0, 4) is 'test' and typeof @[prop] is 'function'
                    @_writeTestName "Running test: #{@_formatTestName prop}"
                    console.warn "Running test: #{@_formatTestName prop}"

                    try
                        @.before?()
                        @[prop]()
                        @.after?()

                    catch error
                        @_writeError error.message
                        @_flushBuffer()
                        throw error

                    console.log ''

            @.class.after =>

                console.log ''
                @_flushBuffer()

    _write: (templateName, string) ->

        template = document.getElementById "tmpl-#{templateName}"
        @_outputBuffer.push Mustache.render template.innerHTML, text: string

    _writeModuleName: (string) -> @_write 'module-title', string

    _writeTestName: (string) -> @_write 'test-title', string

    _writeMessage: (string) -> @_write 'message', string

    _writeError: (string) -> @_write 'error', string

    _flushBuffer: ->

        results = document.createElement 'DIV'
        results.className = 'test-results'
        results.innerHTML = @_outputBuffer.join ''
        document.body.appendChild results

        # TODO: Find a way to do this without setTimeout setTimeout works 
        # around not scrolling to bottom.
        setTimeout ->
            window.scroll 0, document.body.scrollHeight
        , 1

        @_outputBuffer = []

