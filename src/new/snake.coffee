window.Game ?= {}
class Game.Snake

    # x and y mark the position of the head of the snake
    constructor: (@length = 5, @position) ->

        @direction = null
        @grid = null

        @position ?= new Game.Pair 0, 4
        x = @position.x
        y = @position.y

        # The coordinates of the snake chain
        @chain = ( new Game.Pair x, y - piece for piece in [0..@length - 1] )

        @setupControls()

    setupControls: ->
        $(window).keydown (event) =>
            switch event.keyCode
                when 37 then @direction = 'left'
                when 38 then @direction = 'up'
                when 39 then @direction = 'right'
                when 40 then @direction = 'down'

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquare pair, 'snake' for pair in @chain

    move: ->

        head = @chain[0]
        tail = @chain[@chain.length - 1].clone()

        # TODO: Temporary code to force the snake to move downwards
        return if @position.y >= @grid.squaresY - 1
        @position.y += 1

        moveTo = @position.clone()
        temp = head.clone()

        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.copy moveTo
            moveTo.copy temp
            temp.copy @chain[index + 1]

        @grid.world[tail.x][tail.y].snake = null
