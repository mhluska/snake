define [
    
    'src/piece'
    'src/pair'
    'src/utils'
    'src/world'

    ], (Piece, Pair, Utils, World) ->

    class Grid extends World

        constructor: (@game, @squaresX = 25, @squaresY = 15) ->

            # TODO: Change this so that the user provides grid dimensions and
            # the square dimensions are hard coded. SquaresX and squaresY will
            # be calculated.
            @squareWidth = 15
            @squareHeight = 15

            @pieceTypes = ['food', 'snake']

            @_world = null

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

        eachSquare: (callback, faceIndex = 0) ->

            return unless @_world

            for column, x in @_world
                for square, y in column
                    pos = new Pair x, y, faceIndex
                    return false if false is callback pos, square

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
            visited = {}

            # TODO: Our graphEdges data structure has duplicate edges but it 
            # doesn't matter for now
            @eachSquare (pos) =>

                return if @squareHasType 'snake', pos

                visited[pos] = true

                @eachAdjacentPosition pos, (adjPos, direction) =>

                    unless visited[adjPos] or @squareHasType 'snake', adjPos

                        graphEdges.push [ pos.toString(), adjPos.toString() ]

            graphEdges
