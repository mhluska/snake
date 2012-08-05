define ['src/utils'], (Utils) ->

    class Square

        # TODO: Pass in a Vector3 if we end up needing to make such a class.
        constructor: (@x, @y, @z) ->

            @neighbours = {}
            @pieces = []
            @status = 'off'
            @node = null

        @sideLength: 15

        connect: (square, direction) ->

            @neighbours[direction] = square
            square.neighbours[Utils.opposite direction] = @

        toString: -> "(#{@x}, #{@y}, #{@z})"
