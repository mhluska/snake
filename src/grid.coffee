class SNAKE.Grid

    constructor: (@game, @snake, @squaresX = 25, @squaresY = 15) ->

        @graphics = null

        @squareTypes = ['food', 'snake']

        @foodCount = 0
        @foodItems = null

    _squareToEdges: (pos) =>

        return if @squareHasType('snake', pos) and not pos.equals @snake.head

        edges = []
        @eachAdjacentPosition pos, (adjacentPos, direction) =>
            return if @squareHasType 'snake', adjacentPos
            edges.push [ pos.toString(), adjacentPos.toString() ]

        edges

    _unregisterAllTypesAt: (pos) ->
        @unregisterSquareAt pos, type for type in @squareTypes

    makeWorld: ->
        @eachSquare (pos) => @_unregisterAllTypesAt pos

    setup: (graphics) ->
        @graphics = graphics

    isEmptySquare: (square) ->

        for type in @squareTypes
            return false if square[type]
        true

    registerFoodAt: (pos) ->
        return false unless @registerSquareAt pos, 'food'
        @foodCount += 1
        true

    unregisterFoodAt: (pos) ->
        return false unless @unregisterSquareAt pos, 'food'
        @foodCount -= 1
        true

    registerSquareAt: (pos, type) ->
        return false if @squareAt pos, type
        @squareAt pos, type, true
        true

    unregisterSquareAt: (pos, type) ->

        return false unless @squareHasType type, pos
        # The square will float around invisible until the graphics module
        # decides to clean it up
        # TODO: Make a queue to keep track of these hidden nodes and garbage 
        # collect them after a while or after game over
        @graphics.hideEntity @squareAt pos, type
        @squareAt pos, type, null
        true

    squareHasFood: (pos) ->
        return false unless pos
        @squareHasType 'food', pos

    moveSquare: (start, end, type) ->

        @squareAt end, type, @squareAt start, type
        @squareAt start, type, null

    squareHasType: (type, pos) -> (@squareAt pos, type)?

    visibleFood: ->

        # TODO: This is kind of cheating: accessing the array implementation
        # underneath the queue. Use the more general linked list as an
        # implementation so that you can iterate it and still have O(1) enqueue
        # and dequeue
        foodPositions = []
        for foodPos in @foodItems._queue
            if @graphics.entityIsVisible @squareAt(foodPos).food
                foodPositions.push foodPos
        
        foodPositions

    dropFood: (pos) =>

        pos ?= SNAKE.Utils.randPair @squaresX - 1, @squaresY - 1
        @foodItems.enqueue pos
        @foodItems.dequeue() if @foodCount > @maxFood

    toGraph: ->

        graphEdges = []

        # TODO: Our graphEdges data structure has duplicate edges but it 
        # doesn't matter for now
        @eachSquare (pos) => SNAKE.Utils.concat graphEdges, @_squareToEdges pos
        graphEdges
