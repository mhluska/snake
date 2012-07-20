class SNAKE.Grid2 extends SNAKE.Grid

    constructor: (@game, @snake) ->

        super @game, @snake

        @squareWidth = 15
        @squareHeight = 15
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

    moveSquare: (start, end, type) ->

        @world[end.x][end.y][type] = @world[start.x][start.y][type]
        @world[start.x][start.y][type] = null

    registerSquareAt: (pos, type) ->
        return false if @world[pos.x][pos.y][type]
        @world[pos.x][pos.y][type] = true
        true

    unregisterSquareAt: (pos, type) ->

        return false unless @squareHasType type, pos
        # The square will float around invisible until the graphics module
        # decides to clean it up
        # TODO: Make a queue to keep track of these hidden nodes and garbage 
        # collect them after a while or after game over
        @graphics.hideEntity @world[pos.x][pos.y][type]
        @world[pos.x][pos.y][type] = null
        true

    squareHasType: (type, pos) -> @world[pos.x][pos.y][type]?

    visibleFood: ->

        # TODO: This is kind of cheating: accessing the array implementation
        # underneath the queue. Use the more general linked list as an
        # implementation so that you can iterate it and still have O(1) enqueue
        # and dequeue
        foodPositions = []
        for foodPos in @foodItems._queue
            if @graphics.entityIsVisible @world[foodPos.x][foodPos.y].food
                foodPositions.push foodPos
        
        foodPositions


