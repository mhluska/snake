define [
    
    'jquery'
    'src/utils'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Vector3, Const) ->

    class Snake

        constructor: (@_faces, @_score) ->

            @_orientation =
                up:    Const.normalY.clone()
                right: Const.normalX.clone()
                down:  Const.normalNegY.clone()
                left:  Const.normalNegX.clone()

            @_length = 15

            @_direction = 'up'
            @_directionVec = @_orientation[@_direction]
            @_directionQueue = []

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

            if @_directionQueue.length
                [@_direction, @_directionVec] = @_directionQueue.shift()

            newHead = @head.neighbours[@_directionVec]
            @pieces.push newHead

            @_checkSnakeAt newHead
            @_checkFoodAt newHead

            @tail = @pieces[0]

            @prevHead = @head
            @head = newHead
            @head.on()

            # The snake has entered a new face.
            if @onNewFace()

                directionVecBack = @prevHead.face.normal.clone()
                @_directionVec = directionVecBack.clone().negate()

                @_orientation[@_direction] = @_directionVec
                @_orientation[Utils.opposite @_direction] = directionVecBack

        _checkFoodAt: (square) ->

            if square.has 'food'
                @_score.add()
            else
                @tail.off()
                @pieces.shift()

            square.remove 'food'

        _checkSnakeAt: (square) ->

            return unless square.has 'snake'

            for piece, index in @pieces

                piece.status = 'dead'

                if piece.position.equals square.position

                    @pieces = @pieces.slice index
                    @_score.sub index, true
                    return

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

            newDirectionVec = @_orientation[direction]

            if @_directionQueue.length is 0
                prevDirectionVec = @_directionVec
            else
                prevDirectionVec = @_directionQueue[@_directionQueue.length - 1]?[1]

            if newDirectionVec.dot(prevDirectionVec) is 0
            
                @_nextHead = @head.neighbours[newDirectionVec]
                @_directionQueue.push [direction, newDirectionVec]
