define ['pair', 'utils'], (Pair, Utils) ->

    class Grid

        constructor: (@game, @squaresX = 25, @squaresY = 15) ->

            @graphics = null

            @squareWidth = 15
            @squareHeight = 15

            @foodCount = 0
            @maxFood = 4
            @foodItems = null

            @squareTypes = ['food', 'snake']

            @world = null

        _squareToEdges: (pos) =>

            return if @squareHasType 'snake', pos

            edges = []
            @eachAdjacentPosition pos, (adjacentPos, direction) =>
                return if @squareHasType 'snake', adjacentPos
                edges.push [ pos.toString(), adjacentPos.toString() ]

            edges

        _unregisterAllTypesAt: (pos) ->
            @unregisterSquareAt pos, type for type in @squareTypes

        visibleFood: ->

            # TODO: This is kind of cheating: accessing the array 
            # implementation underneath the queue. Use the more general linked 
            # list as an implementation so that you can iterate it and still 
            # have O(1) enqueue and dequeue
            foodPositions = []
            for foodPos in @foodItems._queue
                if @graphics.entityIsVisible @squareAt(foodPos).food
                    foodPositions.push foodPos
            
            foodPositions

        dropFood: (pos) =>

            pos ?= Utils.randPair @squaresX - 1, @squaresY - 1
            @foodItems.enqueue pos
            @foodItems.dequeue() if @foodCount > @maxFood

        makeWorld: ->
            @eachSquare (pos) => @_unregisterAllTypesAt pos
            @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

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
                    pos = new Pair x, y
                    callback pos, square

        # Iterate over adjacent positions, taking into account wrap around
        eachAdjacentPosition: (pos, callback) ->

            positions =
                down:   new Pair pos.x, pos.y + 1
                right:  new Pair pos.x + 1, pos.y
                up:     new Pair pos.x, pos.y - 1
                left:   new Pair pos.x - 1, pos.y

            for direction, adjacentPos of positions
                normalizedPos = @moduloBoundaries adjacentPos
                return if false is callback normalizedPos, direction

        squareAt: (pos, type, value) ->

          return @world[pos.x][pos.y] if arguments.length is 1
          return @world[pos.x][pos.y][type] if arguments.length is 2
          @world[pos.x][pos.y][type] = value

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

        toGraph: ->

            graphEdges = []

            # TODO: Our graphEdges data structure has duplicate edges but it 
            # doesn't matter for now
            @eachSquare (pos) => Utils.concat graphEdges, @_squareToEdges pos
            graphEdges
