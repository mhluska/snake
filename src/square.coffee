define ->

    class Square

        # TODO: Pass in a Vector3 if we end up needing to make such a class.
        constructor: (@x, @y, @z) ->

            @neighbours = {}

        connect: (square, direction) ->

            @neighbours[direction] = square
