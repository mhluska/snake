class SNAKE.Queue

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

    back: ->
        @_queue[@size() - 1]

    isEmpty: ->
        @_queue.length is 0

    toString: -> 
        string = @_queue.reverse().toString()
        # We have to do this since reverse modifies in place
        @_queue.reverse()
        string

class SNAKE.FoodQueue extends SNAKE.Queue

    constructor: (@grid, items) ->
        super items

    enqueue: (item) ->
        super item
        @grid.registerFoodAt item

    dequeue: ->
        # Remove any food positions that the snake has already eaten
        super() until @grid.squareHasFood @peek()
        foodPos = super()
        @grid.unregisterFoodAt foodPos
