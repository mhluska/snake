define ['src/utils', 'src/constants'], (Utils, Const) ->

    class Square

        # TODO: Pass in a Vector3 if we end up needing to make such a class.
        constructor: (@face, @x, @y, @z) ->

            @neighbours = {}
            @pieces = []
            @status = 'off'
            @node = null

        connect: (square, direction) ->

            return unless square

            @neighbours[direction] = square

        toString: -> "(#{@x}, #{@y}, #{@z})"

        adjacentTo: (square) ->

            adjacencies = 0
            adjacencies += 1 if Math.abs(@x - square.x) is Const.squareSize
            adjacencies += 1 if Math.abs(@y - square.y) is Const.squareSize
            adjacencies += 1 if Math.abs(@z - square.z) is Const.squareSize
            
            adjacencies is 1
