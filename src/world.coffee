# Common functions between Cube and Grid

define ['src/pair'], (Pair) ->

    class World

        registerSquareAt: (pos, type) ->
            return false if @squareAt pos, type
            @squareAt pos, type, true
            true

        unregisterSquareAt: (pos, type) ->

            return false unless @squareHasType type, pos
            # The square will float around invisible until the graphics module
            # decides to clean it up
            # TODO: Make a queue to keep track of these hidden nodes and 
            # garbage collect them after a while or after game over
            @graphics.hideEntity @squareAt pos, type
            @squareAt pos, type, null
            true

        squareHasType: (type, pos) -> (@squareAt pos, type)?

        registerFoodAt: (pos) ->
            return false unless @registerSquareAt pos, 'food'
            @game.foodCount += 1
            true

        unregisterFoodAt: (pos) ->
            return false unless @unregisterSquareAt pos, 'food'
            @game.foodCount -= 1
            true

        squareHasFood: (pos) ->
            return false unless pos
            @squareHasType 'food', pos

        # Handles wrap around of pair coordinates on the game world
        moduloBoundaries: (pair, squaresX, squaresY) ->

            pair.x %= @squaresX
            pair.y %= @squaresY
            pair.x = @squaresX - 1 if pair.x < 0
            pair.y = @squaresY - 1 if pair.y < 0

            pair

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

