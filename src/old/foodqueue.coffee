define ['src/queue'], (Queue) ->

    class FoodQueue extends Queue

        constructor: (@grid, @maxFood, items) ->
            super items

        foodCount: 0

        enqueue: (item) ->
            super item
            @grid.squareAt(item).food.show()
            @foodCount += 1
            @dequeue() if @foodCount > @maxFood

        dequeue: ->
            # Remove any food positions that the snake has already eaten
            super() until @grid.squareHasFood @peek()
            foodPos = super()
            @grid.squareAt(foodPos).food.hide()
            @foodCount -= 1
            foodPos
