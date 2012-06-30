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

# A fake queue implementation using arrays since efficiency doesn't matter yet
# TODO: Move things like this to a lib file if there are more data structures
class Game.Queue

    constructor: (items = []) ->
        @_queue = items

    enqueue: (item) ->
        @_queue.push item

    dequeue: ->
        return null unless @size()
        @_queue.shift()

    size: -> @_queue.length

    peek: ->
        @_queue[0]

    isEmpty: ->
        @_queue.length is 0

    toString: -> 
        string = @_queue.reverse().toString()
        # We have to do this since reverse modifies in place
        @_queue.reverse()
        string


