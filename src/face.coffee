define ['src/square'], (Square) ->

    class Face

        constructor: (@normal, @offset = false) ->

            @_squareCount = 15
            @_squareSideLength = 15
            @_sideLength = @_squareCount * @_squareSideLength

            @_buildFace()
            @_connectSquares()

        # The notion of up, right, down, left is with respect to a front view
        # of a face, with face 0 being normal to the X axis and face 1 being
        # normal to the Y axis.
        connect: (face) ->

            if @normal is 'x'

                if face.normal is 'y'

                    otherEdge = face.rightEdge()
                    direction = if face.offset then 'up' else 'down'

                if face.normal is 'z'

                    if face.offset
                        direction = 'left'
                        otherEdge = face.rightEdge()
                    else
                        direction = 'right'
                        otherEdge = face.leftEdge()

            if @normal is 'y'

                if face.normal is 'x'

                    otherEdge = face.topEdge()
                    direction = if face.offset then 'right' else 'left'

                if face.normal is 'z'

                    otherEdge = face.topEdge()
                    direction = if face.offset then 'down' else 'up'

            if @normal is 'z'

                if face.normal is 'x'

                    if face.offset
                        direction = 'right'
                        otherEdge = face.leftEdge()
                    else
                        direction = 'left'
                        otherEdge = face.rightEdge()

                if face.normal is 'y'

                    if face.offset
                        direction = 'up'
                        otherEdge = face.bottomEdge()
                    else
                        direction = 'down'
                        otherEdge = face.topEdge()

            # TODO: Find a better solution for joining edges. This is a hack.
            edge = @_getEdge direction

            return unless edge.length

            if @normal in ['x', 'y'] and face.normal in ['x', 'y']
                if edge[0].z isnt otherEdge[0].z
                    console.log 'reversing!'
                    edge.reverse()

            for square, index in edge
                console.log "connecting #{square.toString()} #{otherEdge[index].toString()}"
                square.connect otherEdge[index], direction

        topEdge: ->
            @squares[index][@_squareCount - 1] for index in [0...@_squareCount]

        rightEdge: ->
            @squares[@_squareCount - 1][index] for index in [0...@_squareCount]

        bottomEdge: ->
            @squares[index][0] for index in [0...@_squareCount]

        leftEdge: ->
            @squares[0][index] for index in [0...@_squareCount]

        _getEdge: (direction) ->

            switch direction
                when 'up' then @topEdge()
                when 'right' then @rightEdge()
                when 'down' then @bottomEdge()
                when 'left' then @leftEdge()
                else []

        _orderArgs: (val1, val2) ->

            offsetAmount = if @offset then @_sideLength else 0

            # The face arrays are filled from the bottom left of a face, so in 
            # these cases the z positions need to be reversed.
            val2 = @_sideLength - val2 if @normal is 'y' and @offset
            val1 = @_sideLength - val1 if @normal is 'x' and @offset

            return [offsetAmount, val2, val1] if @normal is 'x'
            return [val1, offsetAmount, val2] if @normal is 'y'
            return [val1, val2, offsetAmount] if @normal is 'z'

        _buildFace: ->

            @squares = []
            for x in [0...@_squareCount]

                @squares[x] = []
                for y in [0...@_squareCount]

                    posX = x * @_squareSideLength
                    posY = y * @_squareSideLength

                    @squares[x][y] = new Square @_orderArgs(posX, posY)...

        _adjacentPositions: (x, y) ->

            directions = {}
            directions.up =    [x, y + 1] if y < @_squareCount - 1
            directions.right = [x + 1, y] if x < @_squareCount - 1
            directions.down =  [x, y - 1] if y > 0
            directions.left =  [x - 1, y] if x > 0
            directions

        _connectSquares: ->

            for x in [0...@_squareCount]
                for y in [0...@_squareCount]

                    for direction, pos of @_adjacentPositions x, y

                        [xNew, yNew] = pos
                        @squares[x][y].connect @squares[xNew][yNew], direction

