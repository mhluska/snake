class SNAKE.Cube

    constructor: (@game, @length = 15) ->

        @faces = (new SNAKE.Grid(game, @length, @length) for index in [0..5])

    registerSquareAt: ->
