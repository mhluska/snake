class SNAKE.Utils

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

        new SNAKE.Pair randX, randY

    # Concat in place
    @concat: (array1, array2) -> array1.push.apply array1, array2

    @argsToArray: (args) -> Array.prototype.slice.call args

    # minArray([array1, ...])
    # Find the first occurring smallest array of arrays
    @minArray: =>

        return Infinity unless arguments.length

        args = @argsToArray arguments

        lengths = args.map (array) -> array.length
        minLength = Math.min.apply null, lengths
        args[lengths.indexOf minLength]
