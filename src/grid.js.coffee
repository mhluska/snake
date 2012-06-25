window.Game ?= {}
Game.Grid = class Grid
    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->
    
        @snake.cage @squaresX, @squaresY
    
        # gridData holds the contents of each cell (snake, food etc.)
        @gridData = ( ({} for [0...@squaresY]) for [0...@squaresX] )
        @grid = $('<div id="grid"></div>')

        @squareWidth = 15
        @squareHeight = 15

        @grid.width @squareWidth * @squaresX
        @grid.height @squareHeight * @squaresY
        
        @snakeSquares = @snake.chain.map (piece) => @makeSquare 'snake', piece.x, piece.y
        
        @grid.insertBefore $('body script').eq(0)

        @maxFood = 4
        @foodQueue = @makeFoodQueue @maxFood
        @foodDropRate = 10000
        @foodIntervalID = null
        @dropFood()

    resetFoodInterval: ->
        clearInterval @foodIntervalID
        @foodIntervalID = setInterval @dropFood, @foodDropRate

    makeFoodQueue: (maxFood) ->
        queue = []
        queue.push @makeSquare 'food' for [0...maxFood]
        queue

    # TODO: This shouldn't be in grid
    randInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    # TODO: This shouldn't be in grid
    moveToBack: (queue, item) ->
        queueIndex = queue.indexOf item
        @foodQueue.splice 1, queueIndex
        @foodQueue.unshift item

    makeSquare: (type, x = null, y = null) ->
        square = $("<div class='#{type}'></div>")

        # TODO: Is this an antipattern: adding properties to the jQuery node on
        # the fly? Should probably create a wrapper object
        square.type = type
        square.x = x
        square.y = y

        square.width(@squareWidth).height(@squareHeight)
        square.appendTo @grid

    moveSquare: (square, x, y) ->

        @gridData[square.x][square.y][square.type] = null if square.x and square.y
        @gridData[x][y][square.type] = square

        square.css
            left: x * @squareWidth + @grid.offset().left
            top: y * @squareHeight + @grid.offset().top

        square.show()

    dropFood: =>

        return unless @foodQueue.length

        randX = @randInt 0, @squareWidth - 1
        randY = @randInt 0, @squareHeight - 1

        foodItem = @foodQueue.pop()
        @foodQueue.unshift foodItem
        @moveSquare foodItem, randX, randY

        @resetFoodInterval()

    update: ->

        @feedSnake()

        for piece, index in @snake.chain
            @moveSquare @snakeSquares[index], piece.x, piece.y

    feedSnake: (food) ->

        head = @snake.chain[0]

        # TODO: Fix this
        @restart() if @gridData[head.x][head.y].snake

        food = @gridData[head.x][head.y].food

        return unless food

        # Remove the food item from the game
        food.hide()
        @moveToBack @foodQueue, food
        @gridData[head.x][head.y].food = null

        position = @snake.grow()
        @snakeSquares.push @makeSquare 'snake', position.x, position.y
        @dropFood()

    restart: ->
        console.log 'restarting'
