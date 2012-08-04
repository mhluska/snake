# Common functions between Cube and Grid

define ['src/pair'], (Pair) ->

    class World

        squareHasType: (type, pos) -> (@squareAt pos, type).visible()

        squareHasFood: (pos) ->
            return false unless pos
            @squareHasType 'food', pos

        # Handles wrap around of pair coordinates on the game world
        moduloBoundaries: (pair) ->

            pair.x %= @squaresX
            pair.y %= @squaresY
            pair.x = @squaresX - 1 if pair.x < 0
            pair.y = @squaresY - 1 if pair.y < 0

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

