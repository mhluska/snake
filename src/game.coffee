define [
    
    'src/face'
    'src/snake'
    'src/graphics3'

    ], (Face, Snake, Graphics3) ->
    
    class Game

        constructor: (container) ->

            @_timeStepRate = 100

            @_buildCube()

            @_snake = new Snake @faces
            @_graphics = new Graphics3 @faces, container

            console.log 'constructed'
            window.game = @

        run: ->

            setInterval =>

                @_snake.move()
                @_graphics.update()

            , @_timeStepRate

        _buildCube: ->

            @faces = []

            @faces.push new Face 'x', true
            @faces.push new Face 'y', true
            @faces.push new Face 'z', true
            @faces.push new Face 'x'
            @faces.push new Face 'y'
            @faces.push new Face 'z'

            for face, index in @faces
                for otherFace, index2 in @faces when index2 > index
                    face.connect otherFace
