# Based on http://code.stephenmorley.org/javascript/queues/

define ->

    class Queue

        constructor: (arr = []) ->

            @_queue = []
            @_offset = 0
            @_length = 0

            @enqueue item for item in arr

        length: -> @_length - @_offset

        isEmpty: -> @length() is 0

        enqueue: (item) ->
            
            @_queue.push item
            @_length += 1
            item

        dequeue: ->

            return if @_length is 0

            item = @_queue[@_offset]
            @_offset += 1

            if @_offset * 2 >= @_length

                @_queue = @_queue.slice @_offset
                @_length -= @_offset
                @_offset = 0

            item

        peek: ->

            @_queue[@_offset] if @_length > 0

        last: ->

            @_queue[@_length - 1]

        toString: -> @_queue.toString()
