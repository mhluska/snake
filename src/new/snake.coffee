window.Game ?= {}
class Game.Snake

    constructor: (@length = 5, @direction = 'down', @position) ->

        @grid = null
        @lastTailPos = null
        @nextDirection = @direction

        # The number of times the snake will grow when it eats
        @growthPerFood = 3
        @toGrow = 0
        @grown = 0
        @eating = false

        @position ?= new Game.Pair 0, 4
        x = @position.x
        y = @position.y

        # The coordinates of the snake chain
        @chain = ( new Game.Pair x, y - piece for piece in [0..@length - 1] )

        @setupControls()

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquare pair, 'snake' for pair in @chain

    setupControls: ->
        $(window).keydown (event) =>
            newDirection = @direction
            switch event.keyCode
                when 37 then newDirection = 'left'
                when 38 then newDirection = 'up'
                when 39 then newDirection = 'right'
                when 40 then newDirection = 'down'
                
            @nextDirection = newDirection unless @isOpposite newDirection

    isOpposite: (newDirection) ->
        return true if newDirection is 'left' and @direction is 'right'
        return true if newDirection is 'right' and @direction is 'left'
        return true if newDirection is 'up' and @direction is 'down'
        return true if newDirection is 'down' and @direction is 'up'
        false

    updateHeadPosition: ->

        @direction = @nextDirection

        switch @direction
            when 'up'    then @position.y -= 1
            when 'right' then @position.x += 1
            when 'down'  then @position.y += 1
            when 'left'  then @position.x -= 1

        @position.x += @grid.squaresX if @position.x < 0
        @position.x %= @grid.squaresX

        @position.y += @grid.squaresY if @position.y < 0
        @position.y %= @grid.squaresY

    move: ->

        return unless @direction

        @updateHeadPosition()

        head = @chain[0]
        @lastTailPos = @chain[@chain.length - 1].clone()

        temp = head.clone()
        moveTo = @position.clone()

        @grid.restart() if @grid.hasType 'snake', moveTo

        # TODO: Make this constant time instead of linear
        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.copy moveTo
            moveTo.copy temp
            temp.copy @chain[index + 1]

        if @grid.hasType 'food', head
            @toGrow += @growthPerFood
            @eating = true

        @eat() if @eating

    eat: ->
        
        return unless @lastTailPos

        @chain.push @lastTailPos
        @grid.registerSquare @lastTailPos, 'snake'
        @grid.unregisterSquareAt @chain[0], 'food'

        @grown += 1

        if @grown is @toGrow
            @eating = false
            @toGrow = 0
            @grown = 0
