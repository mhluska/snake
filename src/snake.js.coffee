window.Game ?= {}
Game.Snake = class Snake
    constructor: (@direction = 'down') ->
    
        @x = 4
        @y = 4
        @length = 6
        @boundaryX = null
        @boundaryY = null
        
        @queuedDirection = @direction
        
        @chain = ( { x: @x, y: @y- piece } for piece in [0..@length - 1] )
        
        @setupControls()
        
    setupControls: ->
        $(window).keydown (event) =>
            newDirection = @queuedDirection
            switch event.keyCode
                when 37 then newDirection = 'left'
                when 38 then newDirection = 'up'
                when 39 then newDirection = 'right'
                when 40 then newDirection = 'down'
                
            @queuedDirection = newDirection unless @isOpposite newDirection

    isOpposite: (newDirection) ->
        return true if newDirection is 'left' and @direction is 'right'
        return true if newDirection is 'right' and @direction is 'left'
        return true if newDirection is 'up' and @direction is 'down'
        return true if newDirection is 'down' and @direction is 'up'
        return false

    cage: (squaresX, squaresY) ->
        @boundaryX = squaresX
        @boundaryY = squaresY

    move: ->
        @direction = @queuedDirection
        switch @direction
            when 'up'
                return if @y <= 0
                @y -= 1
            when 'right'
                return if @x >= @boundaryX - 1
                @x += 1
            when 'down'
                return if @y >= @boundaryY - 1
                @y += 1
            when 'left'
                return if @x <= 0
                @x -= 1
                
        moveTo = x: @x, y: @y
        temp = x: @chain[0].x, y: @chain[0].y
        
        for piece, index in @chain
        
            piece.x = moveTo.x
            piece.y = moveTo.y
            
            moveTo.x = temp.x
            moveTo.y = temp.y
            
            temp.x = @chain[index + 1]?.x
            temp.y = @chain[index + 1]?.y
       
