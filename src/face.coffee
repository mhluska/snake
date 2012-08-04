define ['src/pair', 'src/square'], (Pair, Square) ->

    class Face

        constructor: (@_axis) ->

            @_sideLength = 15
            @_squares = 15

            @_buildFace()

        _orderArgs: (val1, val2) ->

            offset = (@_squares - 1) * (@_sideLength - 1)

            return [offset, val1, val2] if @_axis.x
            return [val1, offset, val2] if @_axis.y
            return [val1, val2, offset] if @_axis.z

        _eachNeighbour: (pos, callback) ->

            positions =
                up:     new Pair pos.x, pos.y + 1
                right:  new Pair pos.x + 1, pos.y
                down:   new Pair pos.x, pos.y - 1
                left:   new Pair pos.x - 1, pos.y

            for direction, adjacent of positions

                continue if adjacent.x < 0 or adjacent.y < 0
                continue if adjacent.x >= @_squares or adjacent.y >= @_squares

                return false if false is callback(adjacent, direction)

        _connectNeighbours: (square, indices) ->

            @_eachNeighbour indices, (adjacent, direction) =>

                @squares[adjacent.x] ?= []

                neighbour = @squares[adjacent.x][adjacent.y]

                unless neighbour

                    adjacentPos = adjacent.multiply @_sideLength - 1
                    args = @_orderArgs adjacentPos.x, adjacentPos.y
                    neighbour = new Square args...
                    @squares[adjacent.x][adjacent.y] = neighbour

                square.connect neighbour, direction

        _buildFace: ->

            @squares = []
            for x in [0...@_squares - 1]

                @squares[x] = []
                for y in [0...@_squares - 1]

                    indices = new Pair x, y
                    pos = indices.multiply @_sideLength - 1

                    @squares[x][y] ?= new Square @_orderArgs(pos.x, pos.y)...

                    @_connectNeighbours @squares[x][y], indices

