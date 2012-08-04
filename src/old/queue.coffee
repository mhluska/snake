define ->

    class Queue

        constructor: (items = []) ->
            @_queue = items

        enqueue: (item) ->
            @_queue.push item

        dequeue: ->
            return null unless @size()
            @_queue.shift()

        size: -> @_queue.length

        peek: ->
            @_queue[0]

        back: ->
            @_queue[@size() - 1]

        isEmpty: ->
            @_queue.length is 0

        toString: ->
            string = @_queue.reverse().toString()
            # We have to do this since reverse modifies in place
            @_queue.reverse()
            string

