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
        @seekingFood = false

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
        $(window).keydown (event) =>
            newDirection = @direction
            switch event.keyCode
                when 37 then newDirection = 'left'
                when 38 then newDirection = 'up'
                when 39 then newDirection = 'right'
                when 40 then newDirection = 'down'
                else return

            unless @_isOpposite newDirection
                @game.log "enqueueing move #{@_nextPosition @moves.back()}"
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

        graph = new SNAKE.Graph @grid.toGraph()
        @game.log ''
        @game.log 'Running Dijkstras!'
        @game.log @grid
        @game.log graph
        # TODO: This is kind of cheating: accessing the array implementation
        # underneath the queue. Convert to array or maintain a separate array
        # of food. Or better yet, make a grid.closestFood function which
        # uses Euclidean distance to find the closest food item to a given
        # pair
        foodPos = @grid.closestFood @head
        @game.log "passing dijkstras foodPos: #{foodPos}"
        pairs = graph.dijkstras @head.toString(), foodPos
        pairs = pairs.map (pair) -> new SNAKE.Pair pair
        @game.log 'dijkstras calculated:'
        @game.log pairs.toString()
        pairs

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquareAt pair, 'snake' for pair in @chain

        # TODO: Do something about this. Its interfering with the graph algo.
        # Factor out enqueue algo pairs and use it here since the game
        # initially starts with the snake in AI mode
        # @moves.enqueue @_nextPosition()

    move: ->

        return unless @direction

        @game.log "start of snake.move: snake has moves: #{@moves._queue.toString()}"

        if @grid.squareHasType 'food', @head
            @toGrow += @growthPerFood
            @eating = true

        @_eat() if @eating

        @seekingFood = false if @moves.isEmpty()

        unless @seekingFood
            @moves.enqueue pair for pair in @_findFoodPath()
            @game.log 'moves after dijkstras'
            @game.log @moves._queue.toString()
            @seekingFood = true

        temp = @head.clone()

        if @moves.isEmpty()
          @head = @_nextPosition()
          @game.log "getting next pos according to dir #{@direction}: #{@head}"
        else
          @game.log "current head is #{@head}"
          newPos = @moves.dequeue()
          @game.log "dequeueing #{newPos}"
          @direction = @_nextDirection newPos
          @game.log "setting direction to #{@direction}"
          @head = newPos

        @game.log @moves._queue.toString()

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

