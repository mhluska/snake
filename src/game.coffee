require.config
    paths:
        'jquery': 'lib/jquery'

    shim:
        'lib/Three.js': 'exports': 'THREE'

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

            @_graphics = new Graphics3 @_getFaces(), container
            @_snake = new Snake @_faces, @_graphics.camera

        run: ->

            requestAnimationFrame => @run()

            # @_snake.move()
            @_graphics.show @_snake.head.face if @_snake.onNewFace()
            @_graphics.update()

        _getFaces: -> face for key, face of @_faces

        _buildCube: ->

            @_faces = [
                new Face Const.normalX.clone()
                new Face Const.normalY.clone()
                new Face Const.normalZ.clone()
                new Face Const.normalNegX.clone()
                new Face Const.normalNegY.clone()
                new Face Const.normalNegZ.clone()
            ]
            
            # @_faces[2].connect @_faces[1]

            for face, index in @_faces
                face.connect otherFace for otherFace in @_faces[index..]
