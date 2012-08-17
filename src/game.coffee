require.config
    paths:
        'jquery': 'lib/jquery'

    shim:
        'lib/Three.js': 'exports': 'THREE'
        'lib/Tween.js': 'exports': 'TWEEN'

define [
    
    'src/face'
    'src/snake'
    'src/utils'
    'src/graphics3'
    'src/constants'

    ], (Face, Snake, Utils, Graphics3, Const) ->
    
    class Game

        constructor: (container) ->

            @_steps = 0

            @_buildCube()

            @_snake = new Snake @_faces
            @_graphics = new Graphics3 @_getFaces(), container

            $(window).keydown (event) =>
                @_dropFood() if event.which is 70

        run: ->

            requestAnimationFrame => @run()

            @_snake.move() if (@_steps % 5) is 0
            @_dropFood() if (@_steps % 100) is 0
            @_graphics.show @_snake.head.face if @_snake.onNewFace()
            @_graphics.update()

            @_steps += 1

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
            
            for face, index in @_faces
                face.connect otherFace for otherFace in @_faces[index..]

        _dropFood: ->

            face = @_faces[Utils.randInt 0, @_faces.length - 1]

            randX = Utils.randInt 0, Const.squareCount - 1
            randY = Utils.randInt 0, Const.squareCount - 1

            square = face.squares[randX][randY]
            square.on 'food'
            
