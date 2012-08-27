define ['src/utils', 'src/constants'], (Utils, Const) ->

    class Square

        constructor: (@face, @position) ->

            [@x, @y, @z] = [@position.x, @position.y, @position.z]

            @neighbours = {}
            @status = 'off'

            # TODO: Make it so these references aren't added dynamically.
            # This reference is set during the Game._makeGraph call
            @graph = null

            # The visual element representing this square. This variable should
            # be modified only by the graphics module.
            @node = null

        on: (@item = 'snake') ->

            @graph.removeVertex @ if @item in ['snake', 'poison']
            @status = 'on'
            @

        off: ->

            @graph.addVertex @
            @status = 'off'
            @item = null
            @

        connect: (square) ->

            return unless square
            return if square is @

            direction = square.position.clone().sub @position
            direction.divideScalar Const.squareSize

            # Adjust the connection for faces on edges
            unless direction.isVersor()
                direction[@face.axis] = 0

            @neighbours[direction] = square

            @

        adjacencies: (square) ->

            near = 0
            same = 0
            for axis, value of @position.items()
                if value is square[axis]
                    same += 1
                else if Math.abs(value - square[axis]) is Const.squareSize
                    near += 1

            return 0 if (near + same) isnt 3

            near

        adjacentTo: (square) ->

            @adjacencies(square) is 1

        toString: -> @position.toString()
