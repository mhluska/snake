define [
    
    'jquery'
    'src/utils'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Vector3, Const) ->

    class Snake

        constructor: (@_faces, @_camera) ->

            @_length = 5
            @_direction = Const.normalY.clone()

            @_setupControls()

            startFace = @_faces[Const.startFaceIndex]
            @pieces = (startFace.squares[0][index] for index in [0...@_length])
            @head = @pieces[@_length - 1]
            @prevHead = @pieces[@_length - 2]
            @tail = @pieces[0]

            piece.status = 'on' for piece in @pieces

            $(window).keydown (event) =>
                @move() if event.keyCode is 69

        onNewFace: ->

            not @head.adjacentTo @prevHead

        move: ->

            @tail.status = 'off'

            newHead = @head.neighbours[@_direction]
            @pieces.push newHead
            @pieces.shift()

            @tail = @pieces[0]

            @prevHead = @head
            @head = newHead
            @head.status = 'on'

            # The snake has entered a new face.
            if @onNewFace()
                @_direction = @prevHead.face.normal.clone().negate()

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                newDirection = @_direction
                switch event.keyCode
                    when 37 then newDirection = @_turn 'left'
                    when 38 then newDirection = @_turn 'up'
                    when 39 then newDirection = @_turn 'right'
                    when 40 then newDirection = @_turn 'down'
                    else return

                if newDirection.dot(@_direction) is 0

                    # TODO: Add to move queue here instead
                    @_direction = newDirection

        _turn: (direction) ->

            normal = new Vector3

            return normal.copy @_camera.up if direction is 'up'
            return normal.copy(@_camera.up).negate() if direction is 'down'

            cameraAxis = Utils.getAxis @_camera.up
            faceAxis = Utils.getAxis @head.face.normal
            newAxis = (Utils.difference ['x', 'y', 'z'], [cameraAxis, faceAxis])[0]

            normal[newAxis] = if direction is 'right' then 1 else -1

            normal
