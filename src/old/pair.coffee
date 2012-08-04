define ->

    class Pair

        # In 2D mode, faceIndex is meaningless. In 3D mode it is used to 
        # specify which face of the game cube the 2D position is referring to.
        constructor: (@x = 0, @y = 0, @faceIndex = 0) ->

            if arguments.length > 1
                [@x, @y] = [x, y]

            else if arguments.length is 1
                # Support for contruction using a string '(x, y)'
                @_parsePairString x

        _parsePairString: (string) ->

            regex = /\((\d+), ?(\d+)\)/g
            matches = regex.exec string

            [@x, @y] = [ parseInt(matches[1]), parseInt(matches[2]) ]

        clone: -> new Pair @x, @y, @faceIndex

        copy: (pair) ->

            return unless pair

            [@x, @y, @faceIndex] = [pair.x, pair.y, pair.faceIndex]

        equals: (pair) ->

            return false unless pair

            @x is pair.x and @y is pair.y and @faceIndex is pair.faceIndex

        toString: -> "(#{@x}, #{@y}) [#{@faceIndex}]"

        #TODO: Consider unequal faceIndex in these calculations
        length: -> Math.sqrt @x * @x + @y * @y

        subtract: (pair) -> new Pair @x - pair.x, @y - pair.y

        distanceTo: (pair) -> @subtract(pair).length()

