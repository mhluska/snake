window.Game ?= {}
class Game.Grid
    constructor: (@snake, @graphics) ->
        @snake.grid = @
