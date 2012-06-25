window.Game ?= {}
class Game.Snake

    # x and y mark the position of the head of the snake
    constructor: (@length = 5, @x = 0, @y = 4) ->

        # The coordinates of the snake chain
        @chain = ( new Game.Pair @x, @y - piece for piece in [0..@length - 1] )

    setup: (grid) ->

        @grid = grid

        # Snake registers itself on the grid
        @grid.registerSquare pair, 'snake' for pair in @chain

    move: ->

        head = @chain[0]
        tail =
            x: @chain[@chain.length - 1].x
            y: @chain[@chain.length - 1].y

        # TODO: Temporary code to force the snake to move downwards
        return if @y >= @grid.squaresY - 1
        @y += 1

        moveTo  =   x: @x,     y: @y
        temp    =   x: head.x, y: head.y

        for piece, index in @chain
        
            headNode = @grid.world[piece.x][piece.y].snake.node
            @grid.world[moveTo.x][moveTo.y].snake =
                x: moveTo.x, y: moveTo.y,
                node: headNode
        
            piece.x = moveTo.x
            piece.y = moveTo.y
            
            moveTo.x = temp.x
            moveTo.y = temp.y
            
            temp.x = @chain[index + 1]?.x
            temp.y = @chain[index + 1]?.y

        @grid.world[tail.x][tail.y].snake = null
