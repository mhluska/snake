define ->

    class Pair

        constructor: (@x, @y) ->

        multiply: (val) -> new Pair @x * val, @y * val

        toString: -> "(#{@x}, #{@y})"
