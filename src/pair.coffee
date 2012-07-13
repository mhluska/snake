class SNAKE.Pair

    constructor: (x = 0, y = 0) ->

        if arguments.length is 2
            [@x, @y] = [x, y]
            return

        # Support for contruction using a string '(x, y)'
        @_parsePairString x

    _parsePairString: (string) ->

        regex = /\((\d+), ?(\d+)\)/g
        matches = regex.exec string

        [@x, @y] = [ parseInt(matches[1]), parseInt(matches[2]) ]

    clone: -> new SNAKE.Pair @x, @y

    copy: (pair) ->

        return unless pair

        @x = pair.x
        @y = pair.y

    equals: (pair) ->

        return false unless pair
        return @x is pair.x and @y is pair.y

    toString: -> "(#{@x}, #{@y})"
