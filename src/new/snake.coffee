window.Game ?= {}
class Game.Snake

    # x and y mark the position of the head of the snake
    constructor: (@length = 5, @position) ->

        @position ?= new Game.Pair 0, 4
        x = @position.x
        y = @position.y

        # The coordinates of the snake chain
        @chain = ( new Game.Pair x, y - piece for piece in [0..@length - 1] )

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquare pair, 'snake' for pair in @chain

    move: ->

        head = @chain[0]
        tail = @chain[@chain.length - 1].copy()

        # TODO: Temporary code to force the snake to move downwards
        return if @position.y >= @grid.squaresY - 1
        @position.y += 1

        moveTo = @position.copy()
        temp = head.copy()

        for piece, index in @chain
        
            @grid.moveSquare piece, moveTo, 'snake'
        
            piece.x = moveTo.x
            piece.y = moveTo.y
            
            moveTo.x = temp.x
            moveTo.y = temp.y
            
            temp.x = @chain[index + 1]?.x
            temp.y = @chain[index + 1]?.y

        @grid.world[tail.x][tail.y].snake = null
