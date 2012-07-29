# Common functions between Cube and Grid

define ->

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

