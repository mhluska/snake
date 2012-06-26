window.Game ?= {}
class Game.Grid

    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->

        @graphics = null

        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

        @squareWidth = 15
        @squareHeight = 15
        @squareTypes = ['food', 'snake']

        @snake.setup @

        @maxFood = 4
        @foodIndex = 0
        @foodItems = []
        @foodDropRate = 10000
        @foodIntervalID = null
        @dropFood()

    setup: (graphics) ->
        @graphics = graphics

    moveSquare: (start, end, type) ->

        @world[end.x][end.y][type] = @world[start.x][start.y][type]
        @world[start.x][start.y][type] = null

    isEmptySquare: (square) ->

        for type in @squareTypes
            return false if square[type]
        true

    registerSquare: (pair, type) -> @world[pair.x][pair.y][type] = true

    isRegistered: (type) -> type is true

    # TODO: This shouldn't be in grid
    randInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    randPair: (min1, max1, min2, max2) ->

        # Support for randPair(max1, max2)
        if arguments.length is 2
            randX = @randInt 0, min1
            randY = @randInt 0, max1
        else
            randX = @randInt min1, max1
            randY = @randInt min2, max2

        new Game.Pair randX, randY

    resetFoodInterval: ->
        clearInterval @foodIntervalID
        @foodIntervalID = setInterval @dropFood, @foodDropRate

    dropFood: =>

        @resetFoodInterval()

        # Keep adding food items to the game world until we reach the maximum
        unless @foodItems.length is @maxFood
            item = @randPair @squaresX - 1, @squaresY - 1
            @foodItems.push item
            @registerSquare item, 'food'
            return

        food = @foodItems[@foodIndex]
        newFood = @randPair @squaresX - 1, @squaresY - 1
        @moveSquare food, newFood, 'food'
        @foodItems[@foodIndex].copy newFood
        @foodIndex = (@foodIndex + 1) % @maxFood
