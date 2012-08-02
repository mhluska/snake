define [
    
    'src/piece'
    'src/pair'
    'src/utils'
    'src/world'

    ], (Piece, Pair, Utils, World) ->

    class Grid extends World

        constructor: (@game, @squaresX = 25, @squaresY = 15) ->

            @squareWidth = 15
            @squareHeight = 15

            @pieceTypes = ['food', 'snake']

            @_world = null

        _squareToEdges: (pos) =>

            return if @squareHasType 'snake', pos

            edges = []
            @eachAdjacentPosition pos, (adjacentPos, direction) =>
                return if @squareHasType 'snake', adjacentPos
                edges.push [ pos.toString(), adjacentPos.toString() ]

            edges

        dropFood: (pos) =>

            pos ?= Utils.randPair @squaresX - 1, @squaresY - 1
            @game.foodItems.enqueue pos
            @game.foodItems.dequeue() if @foodCount > @maxFood

        destroyWorld: ->

            @eachSquare (pos, square) ->
                piece.hide() for key, piece of square

        makeWorld: ->

            @_world = []
            for row in [0...@squaresX]

                @_world[row] = []
                for column in [0...@squaresY]

                    @_world[row][column] = {}
                    for type in @pieceTypes

                        @_world[row][column][type] = new Piece null, type

        moduloBoundaries: (pair) ->

            super pair

        eachSquare: (callback) ->

            return unless @_world

            for column, x in @_world
                for square, y in column
                    pos = new Pair x, y
                    callback pos, square

        # squareAt(pos) returns key/value pairs of all the squares at pos.
        # squareAt(pos, type) returns the square at pos with type type.
        # squareAt(pos, type, value) sets the value of the square at pos with
        # type type.
        # Returns undefined if pos is out of bounds of the game world.
        squareAt: (pos, type, value) ->

          return @_world[pos.x][pos.y] if type is undefined
          return @_world[pos.x][pos.y][type] if value is undefined 
          @_world[pos.x][pos.y][type] = value

        toGraph: ->

            graphEdges = []

            # TODO: Our graphEdges data structure has duplicate edges but it 
            # doesn't matter for now
            @eachSquare (pos) => Utils.concat graphEdges, @_squareToEdges pos
            graphEdges
