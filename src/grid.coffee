window.Game ?= {}
class Game.Grid

    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->

        @graphics = null
        @gameIntervalID = null
        @timeStepRate = 100

        @squareWidth = 15
        @squareHeight = 15
        @squareTypes = ['food', 'snake']

        @maxFood = 4
        @foodCount = 0
        @foodItems = null

        @foodDropRate = @timeStepRate * 20
        @foodIntervalID = null

    _squareToEdges: (pos) =>

        return if @squareHasType('snake', pos) and not pos.equals @snake.head

        edges = []
        @eachAdjacentPosition pos, (adjacentPos, direction) =>
            return if @squareHasType 'snake', adjacentPos
            edges.push [ pos.toString(), adjacentPos.toString() ]

        edges

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
                pos = new Game.Pair x, y
                callback pos, square

    # Iterate over adjacent positions, taking into account wrap around
    eachAdjacentPosition: (pos, callback) ->

        positions =
            up:     new Game.Pair pos.x, pos.y + 1
            right:  new Game.Pair pos.x + 1, pos.y
            down:   new Game.Pair pos.x, pos.y - 1
            left:   new Game.Pair pos.x - 1, pos.y

        for direction, adjacentPos in positions
            normalizedPos = @moduloBoundaries adjacentPos
            return if false is callback normalizedPos, direction

    makeWorld: ->
        @eachSquare (pos) => @unregisterAllSquaresAt pos
        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

    setup: (graphics) ->
        @graphics = graphics

    startGame: () ->
        # Don't modify foodCount manually. This is handled by unregisterFoodAt 
        # and registerFoodAt
        @foodCount = 0
        @foodItems = new Game.FoodQueue @

        @snake.setup @
        @dropFood()

        clearInterval @gameIntervalID
        gameLoop = =>
            @snake.move()
            @graphics.update()

        @gameIntervalID = setInterval gameLoop, @timeStepRate
        gameLoop()

    moveSquare: (start, end, type) ->

        @world[end.x][end.y][type] = @world[start.x][start.y][type]
        @world[start.x][start.y][type] = null

    isEmptySquare: (square) ->

        for type in @squareTypes
            return false if square[type]
        true

    registerSquareAt: (pos, type) ->
        return false if @world[pos.x][pos.y][type]
        @world[pos.x][pos.y][type] = true
        true

    registerFoodAt: (pos) ->
        return false unless @registerSquareAt pos, 'food'
        @foodCount += 1
        true

    unregisterSquareAt: (pos, type) ->

        return false unless @world[pos.x][pos.y][type]

        # The square will float around invisible until the graphics module
        # decides to clean it up
        # TODO: Make a queue to keep track of these hidden nodes and garbage 
        # collect them after a while or after game over
        @world[pos.x][pos.y][type]?.hide()
        @world[pos.x][pos.y][type] = null
        true

    unregisterFoodAt: (pos) ->
        return false unless @unregisterSquareAt pos, 'food'
        @foodCount -= 1
        true

    unregisterAllSquaresAt: (pos) ->
        @unregisterSquareAt pos, type for type in @squareTypes

    squareHasType: (type, pos) -> @world[pos.x][pos.y][type]?

    squareHasFood: (pos) -> 
        @squareHasType 'food', pos

    resetFoodInterval: ->
        clearInterval @foodIntervalID
        @foodIntervalID = setInterval @dropFood, @foodDropRate

    dropFood: =>

        @resetFoodInterval()

        @foodItems.enqueue Game.Utils.randPair @squaresX - 1, @squaresY - 1
        @foodItems.dequeue() if @foodCount > @maxFood

    restart: ->
        console.log 'restarting'
        @snake = new Game.Snake
        @makeWorld()
        @startGame()

    toGraph: ->

        graphEdges = []

        # TODO: Our graphEdges data structure has duplicate edges but it 
        # doesn't matter for now.
        @eachSquare (pos) => Game.Utils.concat graphEdges, @_squareToEdges pos
        graphEdges
