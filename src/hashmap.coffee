# Temporary HashMap implementation. Relies on toString()

define ->

    class HashMap

        constructor: ->

            @size = 0
            @_set = {}

        add: (key, value) ->

            value = key if arguments.length is 1

            @size += 1
            @_set[key] = value

        get: (key) ->

            @_set[key]

        remove: (key) ->

            @size -= 1
            delete @_set[key]
            key

        clear: ->

            @size = 0
            @_set = {}

        has: (item) ->

            @_set.hasOwnProperty item

        values: ->

            value for key, value of @_set
