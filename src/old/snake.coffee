# TODO: Use private syntax for member variables

define [
    
    'jquery'
    'src/queue'
    'src/pair'
    'src/graph'

    ], ($, Queue, Pair, Graph) ->

    class Snake

        constructor: (@game, @grid, @length = 5, @direction = 'down', @head = null) ->

            @lastTailPos = null
            @moves = new Queue

            # The number of times the snake will grow when it eats
            @stepsPerGrowth = 3
            @growUntil = 0

            # Whether the AI has set the snake to find food
            @autoPlay = false

            @head ?= new Pair 0, 4
            x = @head.x
            y = @head.y

            # The coordinates of the snake chain
            @chain = ( new Pair x, y - piece for piece in [0..@length - 1] )
            @grid.squareAt(pair, 'snake').show() for pair in @chain

            @_setupControls()

        _nextPosition: (position = @head) ->
            nextPos = position.clone()
            switch @direction
                when 'up'    then nextPos.y -= 1
                when 'right' then nextPos.x += 1
                when 'down'  then nextPos.y += 1
                when 'left'  then nextPos.x -= 1

            @grid.moduloBoundaries nextPos

            return nextPos unless @autoPlay

            @_avoidDeathOnPosition nextPos, position

        # Attempts to find another position if the next position results in 
        # death
        _avoidDeathOnPosition: (nextPosition, position) ->

            return nextPosition unless @grid.squareHasType 'snake', nextPosition

            # Find the first adjacent position that has no snake
            @grid.eachAdjacentPosition position, (adjPos, direction) =>

                unless @_isOpposite(direction) or @grid.squareHasType 'snake', adjPos
                  nextPosition = adjPos
                  return false

            nextPosition

        _nextDirection: (position) ->

            return unless position

            nextDirection = @direction
            @grid.eachAdjacentPosition @head, (adjPosition, direction) ->
                if position.equals adjPosition
                    nextDirection = direction
                    return false

            nextDirection

        _setupControls: ->

            $(window).one 'keydown', =>
                return if @game.debugStep
                @autoPlay = false
                @moves.dequeue() until @moves.isEmpty()

            $(window).keydown (event) =>
                newDirection = @direction
                switch event.keyCode
                    when 37 then newDirection = 'left'
                    when 38 then newDirection = 'up'
                    when 39 then newDirection = 'right'
                    when 40 then newDirection = 'down'
                    else return

                unless @_isOpposite newDirection
                    @direction = newDirection
                    @moves.enqueue @_nextPosition @moves.back()

        _isOpposite: (newDirection) ->
            return true if newDirection is 'left' and @direction is 'right'
            return true if newDirection is 'right' and @direction is 'left'
            return true if newDirection is 'up' and @direction is 'down'
            return true if newDirection is 'down' and @direction is 'up'
            false

        _grow: ->
            
            return unless @lastTailPos

            @chain.push @lastTailPos
            @grid.squareAt(@lastTailPos, 'snake').show()
            @grid.squareAt(@chain[0], 'food').hide()

        _visibleFood: ->

            # TODO: This is kind of cheating: accessing the array 
            # implementation underneath the queue. Use the more general linked 
            # list as an implementation so that you can iterate it and still 
            # have O(1) enqueue and dequeue
            foodPositions = []
            for foodPos in @game.foodItems._queue
                if @grid.squareAt(foodPos).food.visible()
                    foodPositions.push foodPos
            
            foodPositions

        # TODO: The snake should adjust its path if a food item spawns
        # closer to it
        _findFoodPath: ->

            foodPositions = @_visibleFood().map (food) -> food.toString()
            return [] unless foodPositions.length

            graph = new Graph @grid.toGraph()

            pairs = graph.dijkstras @head.toString(), foodPositions...
            pairs = (new Pair pair for pair in pairs)

        _updateMoves: ->
            if @autoPlay and @moves.isEmpty()
                @moves.enqueue pair for pair in @_findFoodPath()

        _getNextHead: ->
            if @moves.isEmpty() then @_nextPosition() else @moves.dequeue()

        _eating: -> @game.stepCount < @growUntil

        move: ->

            return unless @direction

            if @grid.squareHasType 'food', @head
                @game.foodItems.foodCount -= 1
                @growUntil = @game.stepCount + @stepsPerGrowth

            @_grow() if @_eating()

            nextHead = @_getNextHead()
            @direction = @_nextDirection nextHead
            @head = nextHead

            console.log "in drawPiece: #{@head.toString()}"

            @_updateMoves()

            return @game.restart() if @grid.squareHasType 'snake', @head

            # Move the snake and update his chain of positions
            @lastTailPos = @chain[@chain.length - 1].clone()

            @grid.squareAt(@lastTailPos).snake.hide()
            @grid.squareAt(@head).snake.show()

            @chain.pop()
            @chain.unshift @head.clone()
