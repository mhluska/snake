# Based on http://code.stephenmorley.org/javascript/queues/

define ->

    class Queue

        constructor: ->

            @_queue = []
            @_offset = 0
            @_length = 0

        length: -> @_length - @_offset

        isEmpty: -> @_length is 0

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
