window.Game ?= {}
class Game.Snake

    constructor: (@length = 5, @direction = 'down', @position) ->

        @grid = null
        @nextDirection = @direction

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
        return false unless @direction
        @direction = @nextDirection
        switch @direction
            when 'up'
                return false if @position.y <= 0
                @position.y -= 1
            when 'right'
                return false if @position.x >= @grid.squaresX - 1
                @position.x += 1
            when 'down'
                return false if @position.y >= @grid.squaresY - 1
                @position.y += 1
            when 'left'
                return false if @position.x <= 0
                @position.x -= 1
        true

    move: ->

        return unless @updateHeadPosition()

        head = @chain[0]
        tail = @chain[@chain.length - 1].clone()

        temp = head.clone()
        moveTo = @position.clone()

        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.copy moveTo
            moveTo.copy temp
            temp.copy @chain[index + 1]
