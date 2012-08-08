define [
    
    'src/face'
    'src/snake'
    'src/utils'
    'src/graphics3'
    'src/constants'

    ], (Face, Snake, Utils, Graphics3, Const) ->
    
    class Game

        constructor: (container) ->

            @_timeStepRate = 30
            @_faces = {}

            @_buildCube()

            @_snake = new Snake @_faces
            @_graphics = new Graphics3 @_getFaces(), container

        run: ->

            requestAnimationFrame => @run()

            # @_snake.move()
            @_graphics.show @_snake.head.face if @_snake.onNewFace()
            @_graphics.update()

        _getFaces: -> face for key, face of @_faces

        _buildCube: ->

            @_faces = [
                new Face 'x', true
                new Face 'y', true
                new Face 'z', true
                new Face 'x'
                new Face 'y'
                new Face 'z'
            ]

            for face, index in @_faces
                face.connect otherFace for otherFace in @_faces[index..]
