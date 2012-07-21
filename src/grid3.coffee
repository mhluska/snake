class SNAKE.Grid3 extends SNAKE.Grid

    constructor: (@game, @snake) ->

        super @game, @snake

        @maxFood = 16

        @squareDepth = 15

