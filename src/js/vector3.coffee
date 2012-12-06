define ->

    class Vector3

        constructor: (@x = 0, @y = 0, @z = 0) ->

        items: -> x: @x, y: @y, z: @z

        copy: (vector) ->
            
            [@x, @y, @z] = [vector.x, vector.y, vector.z]

            @

        clone: -> new Vector3 @x, @y, @z

        equals: (x, y, z) ->

            [x, y, z] = [x.x, x.y, x.z] if arguments.length is 1

            @x is x and @y is y and @z is z

        dot: (vector) -> @x * vector.x + @y * vector.y + @z * vector.z

        sub: (vector) ->

            @x -= vector.x
            @y -= vector.y
            @z -= vector.z

            @

        multiplyScalar: (val) ->

            @x *= val
            @y *= val
            @z *= val

            @

        divideScalar: (val) -> @multiplyScalar(1 / val)

        negate: -> @multiplyScalar -1

        lengthSq: -> @dot @

        lengthManhanttan: -> Math.abs(@x) + Math.abs(@y) + Math.abs(@z)

        isVersor: ->

            @lengthSq() is 1 and @lengthManhanttan() is 1

        toString: -> "(#{@x}, #{@y}, #{@z})"
