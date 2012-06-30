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
        @foodQueue = []
        @foodDropRate = @timeStepRate * 20
        @foodIntervalID = null

    eachSquare: (callback) ->

        return unless @world

        for column, x in @world
            for square, y in column
                pos = new Game.Pair x, y
                callback pos, square

    makeWorld: ->
        @eachSquare (pos) => @unregisterSquareAt pos
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

    moveFood: ->

        foodPos = @foodQueue.shift()
        newFoodPos = Game.Utils.randPair @squaresX - 1, @squaresY - 1
        @foodQueue.push newFoodPos

        @moveSquare foodPos, newFoodPos, 'food'

    isEmptySquare: (square) ->

        for type in @squareTypes
            return false if square[type]
        true

    registerSquare: (pos, type) -> @world[pos.x][pos.y][type] = true

    unregisterSquareAt: (pos, types) ->

        # If no types are provided unregister them all
        types = if types then [types] else @squareTypes

        # The square will float around invisible until the graphics module
        # decides to clean it up
        # TODO: Make a queue to keep track of these hidden nodes and garbage 
        # collect them after a while or after game over
        for type in types
            @world[pos.x][pos.y][type]?.hide()
            @world[pos.x][pos.y][type] = null

            @removeFoodAt pos if type is 'food'

    removeFoodAt: (pos) ->
        for foodPos, index in @foodQueue
            @foodQueue.splice index, 1 if pos.equals foodPos

        console.log @foodQueue

    hasType: (type, pos) -> @world[pos.x][pos.y][type]?

    resetFoodInterval: ->
        clearInterval @foodIntervalID
        @foodIntervalID = setInterval @dropFood, @foodDropRate

    dropFood: =>

        @resetFoodInterval()

        # Keep adding food items to the game world until we reach the maximum
        unless @foodQueue.length is @maxFood
            item = Game.Utils.randPair @squaresX - 1, @squaresY - 1
            @foodQueue.push item
            @registerSquare item, 'food'
            return

        @moveFood()

    restart: ->
        @snake = new Game.Snake
        @makeWorld()
        @startGame()

