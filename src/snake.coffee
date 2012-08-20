define [
    
    'jquery'
    'src/utils'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Vector3, Const) ->

    class Snake

        constructor: (@_faces) ->

            @_orientation =
                up:    Const.normalY.clone()
                right: Const.normalX.clone()
                down:  Const.normalNegY.clone()
                left:  Const.normalNegX.clone()

            @_length = 5
            @_direction = 'up'
            @_directionVec = @_orientation[@_direction]

            @_setupControls()

            startFace = @_faces[Const.startFaceIndex]
            @pieces = (startFace.squares[0][index] for index in [0...@_length])
            @head = @pieces[@_length - 1]
            @prevHead = @pieces[@_length - 2]
            @tail = @pieces[0]

            piece.on() for piece in @pieces

        onNewFace: ->

            not @head.adjacentTo @prevHead

        move: ->

            newHead = @head.neighbours[@_directionVec]
            @pieces.push newHead

            unless newHead.has 'food'
                @tail.off()
                @pieces.shift()

            @tail = @pieces[0]

            @prevHead = @head
            @head = newHead
            @head.on()

            @head.remove 'food'

            # The snake has entered a new face.
            if @onNewFace()

                @_directionVecBack = @prevHead.face.normal.clone()
                @_directionVec = @_directionVecBack.clone().negate()

                @_orientation[@_direction] = @_directionVec
                @_orientation[Utils.opposite @_direction] = @_directionVecBack

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                switch event.keyCode
                    when 37 then @_turn 'left'
                    when 38 then @_turn 'up'
                    when 39 then @_turn 'right'
                    when 40 then @_turn 'down'
                    else return

        _turn: (direction) ->

            if @_orientation[direction].dot(@_directionVec) is 0
            
                # TODO: Add to move queue here instead
                @_directionVec = @_orientation[direction]
                @_direction = direction
