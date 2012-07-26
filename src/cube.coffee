define ['grid'], (Grid) ->

    class Cube

        constructor: (@game, @length = 15) ->

            @faces = (new Grid(game, @length, @length) for index in [0..5])

        registerSquareAt: ->
