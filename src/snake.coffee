# TODO: Use private syntax for member variables

define ['queue', 'pair', 'graph'], (Queue, Pair, Graph) ->

    class Snake

        constructor: (@game, @length = 5, @direction = 'down', @head = null) ->

            @grid = null
            @lastTailPos = null
            @moves = new Queue

            # The number of times the snake will grow when it eats
            @stepsPerGrowth = 3
            @growUntil = 0

            # Whether the AI has set the snake to find food
            @autoPlay = true

            @head ?= new Pair 0, 4
            x = @head.x
            y = @head.y

            # The coordinates of the snake chain
            @chain = ( new Pair x, y - piece for piece in [0..@length - 1] )

            @_setupControls()

        _nextPosition: (position = @head) ->
            nextPos = position.clone()
            switch @direction
                when 'up'    then nextPos.y -= 1
                when 'right' then nextPos.x += 1
                when 'down'  then nextPos.y += 1
                when 'left'  then nextPos.x -= 1

            nextPos = @grid.moduloBoundaries nextPos

            return nextPos unless @autoPlay

            @_avoidDeathOnPosition nextPos, position

        # Attempts to find another position if the next position results in death
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
            @grid.registerSquareAt @lastTailPos, 'snake'
            @grid.unregisterFoodAt @chain[0]

        _findFoodPath: ->

            foodPositions = @game.visibleFood().map (food) -> food.toString()
            return [] unless foodPositions.length

            graph = new Graph @grid.toGraph()

            pairs = graph.dijkstras @head.toString(), foodPositions...
            pairs = pairs.map (pair) -> new Pair pair
            pairs

        _updateMoves: ->
            if @autoPlay and @moves.isEmpty()
                @moves.enqueue pair for pair in @_findFoodPath()

        _getNextHead: ->
            if @moves.isEmpty() then @_nextPosition() else @moves.dequeue()

        _eating: -> @game.stepCount < @growUntil

        setup: (grid) ->

            @grid = grid

            # Snake registers itself on the grid
            @grid.registerSquareAt pair, 'snake' for pair in @chain

        move: ->

            return unless @direction

            if @grid.squareHasType 'food', @head
                @growUntil = @game.stepCount + @stepsPerGrowth

            @_grow() if @_eating()

            nextHead = @_getNextHead()
            @direction = @_nextDirection nextHead
            @head = nextHead

            @_updateMoves()

            @game.restart() if @grid.squareHasType 'snake', @head

            # Move the snake and update his chain of positions
            @lastTailPos = @chain[@chain.length - 1].clone()
            @grid.moveSquare @lastTailPos, @head, 'snake'
            @chain.pop()
            @chain.unshift @head.clone()

