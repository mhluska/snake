window.Game ?= {}
class Game.Snake

    # x and y mark the position of the head of the snake
    constructor: (@length = 5, @x = 0, @y = 4) ->

        # The coordinates of the snake chain
        @chain = ( { x: @x, y: @y - piece } for piece in [0..@length - 1] )

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.world[piece.x][piece.y].snake = true for piece in @chain

    move: ->

        # TODO: Temporary code to force the snake to move downwards
        @y += 1

        moveTo  =   x: @x,          y: @y
        temp    =   x: @chain[0].x, y: @chain[0].y
        
        for piece, index in @chain
        
            piece.x = moveTo.x
            piece.y = moveTo.y
            
            moveTo.x = temp.x
            moveTo.y = temp.y
            
            temp.x = @chain[index + 1]?.x
            temp.y = @chain[index + 1]?.y
