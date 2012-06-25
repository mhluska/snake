window.Game ?= {}
class Game.Pair
    constructor: (@x = 0, @y = 0) ->
    copy: -> x: @x, y: @y
