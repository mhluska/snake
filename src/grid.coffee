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
        @snake = new Game.Snake
        @makeWorld()
        @startGame()

    toGraph: ->

        graphEdges = []

        # TODO: Our graphEdges data structure has duplicate edges but it 
        # doesn't matter for now.
        @eachSquare (pos) -> @graphEdges.concat @_squareToGraphEdges @, pos
        graphEdges
            

    _squareToGraphEdges: (grid, pos) ->

        return if grid.squareHasType 'snake', pos
        
        # Static variable to uniquely name vertices
        @.vertexCount ?= 0

        # Used to make positions wrap around the board
        squareBottomY = if pos.y is 0 then @squaresY - 1 else pos.x - 1
        squareLeftX = if pos.x is 0 then @squaresX - 1  else pos.x - 1

        squares = [
            Game.Pair pos.x, (pos.y + 1 % @squaresY)
            Game.Pair (pos.x + 1 % @squaresX), pos.y
            Game.Pair pos.x, squaresBottomY
            Game.Pair squareLeftX, pos.y
        ]

        edges = []
        for square in squares
            continue if grid.squareHasType 'snake', square
            edges.push [@.vertexCount, @.vertexCount + 1]
            @.vertexCount += 2

        edges
