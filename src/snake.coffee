window.Game ?= {}
class Game.Snake

    constructor: (@length = 5, @direction = 'down', @head) ->

        @grid = null
        @lastTailPos = null
        @moves = new Game.Queue [@direction]

        # The number of times the snake will grow when it eats
        @growthPerFood = 3
        @toGrow = 0
        @grown = 0
        @eating = false

        # Whether the AI has set the snake to find food
        @seekingFood = false

        @head ?= new Game.Pair 0, 4
        x = @head.x
        y = @head.y

        # The coordinates of the snake chain
        @chain = ( new Game.Pair x, y - piece for piece in [0..@length - 1] )

        @_setupControls()

    _updateHeadPosition: ->

        @direction = @moves.dequeue() unless @moves.isEmpty()

        switch @direction
            when 'up'    then @head.y -= 1
            when 'right' then @head.x += 1
            when 'down'  then @head.y += 1
            when 'left'  then @head.x -= 1

        @head.x += @grid.squaresX if @head.x < 0
        @head.x %= @grid.squaresX

        @head.y += @grid.squaresY if @head.y < 0
        @head.y %= @grid.squaresY

    _setupControls: ->
        $(window).keydown (event) =>
            newDirection = @direction
            switch event.keyCode
                when 37 then newDirection = 'left'
                when 38 then newDirection = 'up'
                when 39 then newDirection = 'right'
                when 40 then newDirection = 'down'

            @moves.enqueue newDirection unless @_isOpposite newDirection

    _isOpposite: (newDirection) ->
        currentDirection = @moves.peek() or @direction
        return true if newDirection is 'left' and currentDirection is 'right'
        return true if newDirection is 'right' and currentDirection is 'left'
        return true if newDirection is 'up' and currentDirection is 'down'
        return true if newDirection is 'down' and currentDirection is 'up'
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

        graph = new Game.Graph @grid.toGraph()
        # TODO: This is kind of cheating: accessing the array implementation
        # underneath the queue. Convert to array or maintain a separate array
        # of food. Or better yet, make a grid.closestFood function which
        # uses Euclidean distance to find the closest food item to a given
        # pair
        foodStrings = @grid.foodItems._queue.map (item) -> item.toString()
        pairs = graph.dijkstras @head.toString(), foodStrings...
        pairs = pairs.map (pair) -> new Game.Pair pair
        pairs.unshift @head
        @_pairsToDirections pairs

    _pairsToDirections: (pairs) ->

        directions = []
        for pair, index in pairs
            if index > 0
                directions.push @grid.pairOrientation pairs[index - 1], pair

        directions

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquareAt pair, 'snake' for pair in @chain

    move: ->

        return unless @direction

        head = @head.clone()

        # unless @seekingFood
        #     @moves.enqueue pair for pair in @_findFoodPath()
        #     @seekingFood = true

        @_updateHeadPosition()

        @lastTailPos = @chain[@chain.length - 1].clone()
        temp = head.clone()
        moveTo = @head.clone()

        @grid.restart() if @grid.squareHasType 'snake', moveTo

        # TODO: Make this constant time instead of linear by updating just the
        # head and tail piece
        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.copy moveTo
            moveTo.copy temp
            temp.copy @chain[index + 1]

        if @grid.squareHasType 'food', head
            @toGrow += @growthPerFood
            @eating = true

        @_eat() if @eating
