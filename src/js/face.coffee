define [
    
    'lib/three'
    'square'
    'constants'
    'utils'

], (THREE, Square, Const, Utils) ->

    class Face

        constructor: (@normal) ->

            @axis = Utils.getAxis @normal

            @_buildFace()
            @_connectSquares()

        connect: (face) ->

            return if face is @
            return if face.axis is @axis

            for edge in @edges()
                for otherEdge in face.edges()

                    continue if @_connectEdges edge, otherEdge

        edges: -> [@_topEdge(), @_rightEdge(), @_bottomEdge(), @_leftEdge()]

        _connectEdges: (edge1, edge2) ->

            nonCornerIndex = 1
            testSquare = edge1[nonCornerIndex]
            testSquare2 = edge2[nonCornerIndex]

            if testSquare.adjacencies(testSquare2) isnt 2

                otherEndSquare = edge2[Const.squareCount - 1 - nonCornerIndex]

                if testSquare.adjacencies(otherEndSquare) is 2
                    edge2.reverse()

                else return false

            for square, index in edge1
                square.connect edge2[index]
                edge2[index].connect square

            true

        _topEdge: ->

            for index in [0...Const.squareCount]
                @squares[index][Const.squareCount - 1]

        _rightEdge: ->

            for index in [0...Const.squareCount]
                @squares[Const.squareCount - 1][index]

        _bottomEdge: ->

            @squares[index][0] for index in [0...Const.squareCount]

        _leftEdge: ->

            @squares[0][index] for index in [0...Const.squareCount]

        _orderArgs: (val1, val2, offset) ->

            # Positions the squares on the surface of the cube.
            offset ?= (Const.cubeSize / 2) + (Const.squareSize / 2)

            args = [@normal.x * offset, val2, val1] if @axis is 'x'
            args = [val1, @normal.y * offset, val2] if @axis is 'y'
            args = [val1, val2, @normal.z * offset] if @axis is 'z'

            new THREE.Vector3 args...

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
                    if @normal.equals Const.normalX
                        posX = Const.cubeSize - posX
                    if @normal.equals Const.normalNegZ
                        posX = Const.cubeSize - posX
                    if @normal.equals Const.normalY
                        posY = Const.cubeSize - posY

                    # Take the cube center into account.
                    posX -= Const.cubeSize / 2
                    posY -= Const.cubeSize / 2

                    @squares[x][y] = new Square \
                        @,
                        @_orderArgs(posX, posY), @_graph

        _adjacentPositions: (x, y) ->

            [ [x, y + 1]
              [x + 1, y]
              [x, y - 1]
              [x - 1, y] ]

        _connectSquares: ->

            for x in [0...Const.squareCount]
                for y in [0...Const.squareCount]
                    for pos in @_adjacentPositions x, y

                        [xNew, yNew] = pos
                        @squares[x][y].connect @squares[xNew]?[yNew]

