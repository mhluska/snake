window.Game ?= {}
class Game.Utils

    @randInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    @randPair: (min1, max1, min2, max2) ->

        # Support for randPair(max1, max2)
        if arguments.length is 2
            randX = @randInt 0, min1
            randY = @randInt 0, max1
        else
            randX = @randInt min1, max1
            randY = @randInt min2, max2

        new Game.Pair randX, randY
