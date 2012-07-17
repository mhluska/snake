class SNAKE.Snake

    constructor: (@game, @length = 5, @direction = 'down', @head) ->

        @grid = null
        @lastTailPos = null
        @moves = new SNAKE.Queue

        # The number of times the snake will grow when it eats
        @growthPerFood = 3
        @toGrow = 0
        @grown = 0
        @eating = false

        # Whether the AI has set the snake to find food
        @autoPlay = true

        @head ?= new SNAKE.Pair 0, 4
        x = @head.x
        y = @head.y

        # The coordinates of the snake chain
        @chain = ( new SNAKE.Pair x, y - piece for piece in [0..@length - 1] )

        @_setupControls()

    _nextPosition: (position = @head) ->
        position = position.clone()
        switch @direction
            when 'up'    then position.y -= 1
            when 'right' then position.x += 1
            when 'down'  then position.y += 1
            when 'left'  then position.x -= 1

        @grid.moduloBoundaries position

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

    _eat: ->
        
        return unless @lastTailPos

        @chain.push @lastTailPos
        @grid.registerSquareAt @lastTailPos, 'snake'
        @grid.unregisterFoodAt @chain[0]

        @grown += 1

        if @grown is @toGrow
            @eating = false
            @toGrow = 0
            @grown = 0

    _findFoodPath: ->

        foodPositions = @grid.visibleFood()
        return [] unless foodPositions.length

        graph = new SNAKE.Graph @grid.toGraph()

        pairs = graph.dijkstras @head.toString(), foodPositions...
        pairs = pairs.map (pair) -> new SNAKE.Pair pair
        pairs

    _startFoodSearch: ->
        if @autoPlay and @moves.isEmpty()
            @moves.enqueue pair for pair in @_findFoodPath()

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquareAt pair, 'snake' for pair in @chain

    move: ->

        return unless @direction

        if @grid.squareHasType 'food', @head
            @toGrow += @growthPerFood
            @eating = true

        @_eat() if @eating

        @_startFoodSearch()

        temp = @head.clone()

        if @moves.isEmpty()
          @head = @_nextPosition()
        else
          newPos = @moves.dequeue()
          @direction = @_nextDirection newPos
          @head = newPos

        moveTo = @head.clone()

        @lastTailPos = @chain[@chain.length - 1].clone()

        @game.restart() if @grid.squareHasType 'snake', moveTo

        # TODO: Make this constant time instead of linear by updating just the
        # head and tail piece
        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.copy moveTo
            moveTo.copy temp
            temp.copy @chain[index + 1]

