class SNAKE.Grid2 extends SNAKE.Grid

    constructor: (@game, @snake) ->

        super @game, @snake

        @maxFood = 4

    # Handles wrap around of pair coordinates on the game world
    moduloBoundaries: (pair) ->

        pair.x %= @squaresX
        pair.y %= @squaresY
        pair.x = @squaresX - 1 if pair.x < 0
        pair.y = @squaresY - 1 if pair.y < 0

        pair

    eachSquare: (callback) ->

        return unless @world

        for column, x in @world
            for square, y in column
                pos = new SNAKE.Pair x, y
                callback pos, square

    # Iterate over adjacent positions, taking into account wrap around
    eachAdjacentPosition: (pos, callback) ->

        positions =
            down:   new SNAKE.Pair pos.x, pos.y + 1
            right:  new SNAKE.Pair pos.x + 1, pos.y
            up:     new SNAKE.Pair pos.x, pos.y - 1
            left:   new SNAKE.Pair pos.x - 1, pos.y

        for direction, adjacentPos of positions
            normalizedPos = @moduloBoundaries adjacentPos
            return if false is callback normalizedPos, direction

    makeWorld: ->
        super()
        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

    squareAt: (pos, type, value) -> 

      return @world[pos.x][pos.y] if arguments.length is 1
      return @world[pos.x][pos.y][type] if arguments.length is 2
      @world[pos.x][pos.y][type] = value

