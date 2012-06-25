window.Game ?= {}
class Game.Pair
    constructor: (@x = 0, @y = 0) ->
    copy: -> new Game.Pair @x, @y
