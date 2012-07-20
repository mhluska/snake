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

    squareHasFood: (pos) ->
        return false unless pos
        @squareHasType 'food', pos

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
