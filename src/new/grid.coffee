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
        @foodQueue = new Game.Queue
        @foodDropRate = @timeStepRate * 20
        @foodIntervalID = null

    eachSquare: (callback) ->

        return unless @world

        for column, x in @world
            for square, y in column
                pos = new Game.Pair x, y
                callback pos, square

    makeWorld: ->
        @eachSquare (pos) => @unregisterAllSquaresAt pos
        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

    setup: (graphics) ->
        @graphics = graphics

    startGame: () ->
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
        @world[pos.x][pos.y][type].hide()
        @world[pos.x][pos.y][type] = null
        true

    unregisterFoodAt: (pos) ->
        return false unless @unregisterSquareAt pos, 'food'

        # TODO: Do some error checking here so that a negative value isn't set
        @foodCount -= 1
        true

    unregisterAllSquaresAt: (pos) ->
        @unregisterSquareAt pos for type in @squareTypes

    squareHasType: (type, pos) -> @world[pos.x][pos.y][type]?

    squareHasFood: (pos) -> 
        @squareHasType 'food', pos

    resetFoodInterval: ->
        clearInterval @foodIntervalID
        @foodIntervalID = setInterval @dropFood, @foodDropRate

    dropFood: =>

        @resetFoodInterval()

        # Keep adding food items to the game world until we reach the maximum
        newFoodPos = Game.Utils.randPair @squaresX - 1, @squaresY - 1
        @foodQueue.enqueue newFoodPos
        @registerFoodAt newFoodPos

        # Remove any food positions that the snake has already eaten
        @foodQueue.dequeue() until @squareHasFood @foodQueue.peek()

        if @foodCount > @maxFood
            foodPos = @foodQueue.dequeue()
            @unregisterFoodAt foodPos

    restart: ->
        @snake = new Game.Snake
        @makeWorld()
        @startGame()

