window.Game ?= {}
class Game.Pair

    constructor: (@x = 0, @y = 0) ->

    clone: -> new Game.Pair @x, @y

    copy: (pair) ->

        return unless pair

        @x = pair.x
        @y = pair.y

    equals: (pair) ->

        return false unless pair
        return @x is pair.x and @y is pair.y

    toString: -> "(#{@x}, #{@y})"
