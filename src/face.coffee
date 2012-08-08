define ['src/square', 'src/constants'], (Square, Const) ->

    class Face

        constructor: (@normal, @offset = false) ->

            @squares = []

            @_buildFace()
            @_connectSquares()

        connect: (face) ->

            return if face is @

            directionOut = @directionTo face

            return unless directionOut

            edgeOut = @getEdge directionOut

            directionIn = face.directionTo @
            edgeIn = face.getEdge directionIn

            @connectEdge edgeOut, edgeIn, directionOut
            face.connectEdge edgeIn, edgeOut, directionIn

        directionTo: (face) ->

            # Returns undefined if they are not adjacent.
            return if @normal is face.normal

            switch @normal

                when 'x'
                    if face.normal is 'y'
                        if face.offset then 'up' else 'down'
                    else
                        if @offset
                            if face.offset then 'left' else 'right'
                        else
                            if face.offset then 'right' else 'left'

                when 'y'
                    if face.normal is 'x'
                        if face.offset then 'right' else 'left'
                    else
                        if @offset
                            if face.offset then 'down' else 'up'
                        else
                            if face.offset then 'up' else 'down'

                when 'z'
                    if face.normal is 'y'
                        if face.offset then 'up' else 'down'
                    else
                        if @offset
                            if face.offset then 'right' else 'left'
                        else
                            if face.offset then 'left' else 'right'

        connectEdge: (edge1, edge2, direction) ->

            square.connect edge2[index], direction for square, index in edge1

        getEdge: (direction) ->

            switch direction
                when 'up' then @_topEdge()
                when 'right' then @_rightEdge()
                when 'down' then @_bottomEdge()
                when 'left' then @_leftEdge()
                else []

        positionFromCentroid: ->

            @_orderArgs 0, 0, Const.cameraFaceOffset

        _topEdge: ->

            edge = (for index in [0...Const.squareCount]
                @squares[index][Const.squareCount - 1])

            edge.reverse() if @normal in ['y', 'z'] and not @offset

            edge

        _rightEdge: ->

            for index in [0...Const.squareCount]
                @squares[Const.squareCount - 1][index]

        _bottomEdge: ->

            edge = (@squares[index][0] for index in [0...Const.squareCount])

            edge.reverse() if @normal in ['x', 'z'] and @offset
            edge.reverse() if @normal is 'y' and not @offset

            edge

        _leftEdge: ->

            edge = (@squares[0][index] for index in [0...Const.squareCount])

            edge.reverse() if @normal is 'y' and @offset

            edge

        _orderArgs: (val1, val2, offset) ->

            # Positions the squares on the surface of the cube.
            offset ?= (Const.cubeSize / 2) + (Const.squareSize / 2)
            offset = -offset unless @offset

            return [offset, val2, val1] if @normal is 'x'
            return [val1, offset, val2] if @normal is 'y'
            return [val1, val2, offset] if @normal is 'z'

        _buildFace: ->

            @squares = []
            for x in [0...Const.squareCount]

                @squares[x] = []
                for y in [0...Const.squareCount]

                    # Map the 2D array indices to square positions on the cube
                    posX = x * Const.squareSize + (Const.squareSize / 2)
                    posY = y * Const.squareSize + (Const.squareSize / 2)

                    # The 2D array is filled from the bottom left, so positions
                    # need to be reversed in the cases where they are filled
                    # in the negative direction of the axis.
                    posX = Const.cubeSize - posX if @normal is 'x' and @offset
                    posX = Const.cubeSize - posX if @normal is 'z' and not @offset
                    posY = Const.cubeSize - posY if @normal is 'y' and @offset

                    # Take the cube center into account.
                    posX -= Const.cubeSize / 2
                    posY -= Const.cubeSize / 2

                    @squares[x][y] = new Square @, @_orderArgs(posX, posY)...

        _adjacentPositions: (x, y) ->

            up:     [x, y + 1]
            right:  [x + 1, y]
            down:   [x, y - 1]
            left:   [x - 1, y]

        _connectSquares: ->

            for x in [0...Const.squareCount]
                for y in [0...Const.squareCount]

                    for direction, pos of @_adjacentPositions x, y

                        [xNew, yNew] = pos
                        @squares[x][y].connect @squares[xNew]?[yNew], direction

