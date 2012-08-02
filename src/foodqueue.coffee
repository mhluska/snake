define ['src/queue'], (Queue) ->

    class FoodQueue extends Queue

        constructor: (@grid, items) ->
            super items

        enqueue: (item) ->
            super item
            @grid.squareAt(item).food.show()

        dequeue: ->
            # Remove any food positions that the snake has already eaten
            super() until @grid.squareHasFood @peek()
            foodPos = super()
            @grid.squareAt(foodPos).food.hide()
