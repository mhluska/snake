# Temporary HashMap implementation. Relies on toString()
# TODO: Publish BinaryHeap and HashMap in a data structures repo on GitHub. 

define ->

    class HashMap

        constructor: (arr = []) ->

            @size = 0
            @_hash = {}
            @_reverseHash = {}

            @add item for item in arr

        # TODO: Implement this. Create a Utils.copyObject.
        clone: ->

        put: (key, value) ->

            value = key if arguments.length is 1

            @size += 1
            @_hash[key] = value
            @_reverseHash[key] = key

        get: (key) ->

            @_hash[key]

        remove: (key) ->

            @size -= 1
            delete @_hash[key]
            delete @_reverseHash[key]
            key

        clear: ->

            @size = 0
            @_hash = {}

        has: (item) ->

            @_hash[item]?

        keys: ->

            @_reverseHash[key] for own key of @_hash

        values: ->

            value for own key, value of @_hash
