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

            @_resetInfection()

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
            @_checkPoisonAt newHead
            @_checkFoodAt newHead
            @_growInfection()

            @tail = @pieces[0]
            @prevHead = @head
            @head = newHead
            @head.off().on()

            # The snake has entered a new face.
            if @onNewFace()

                directionVecBack = @prevHead.face.normal.clone()
                @_directionVec = directionVecBack.clone().negate()

                @_orientation[@_direction] = @_directionVec
                @_orientation[Utils.opposite @_direction] = directionVecBack

        _resetInfection: ->
            
            @_infected = false
            @_infectedMoves = 0
            @_infectionIndex = 0

        _growInfection: ->

            return unless @_infected

            @_infectedMoves += 1
            @_infectionIndex += 1 if @_infectedMoves % 10 is 0

            endIndex = @_length - Const.snakeMinLength + 1
            if @_infectionIndex is endIndex
                @_resetInfection()
                @_checkSnakeAt @pieces[endIndex - 1]
                return

            @pieces[@_infectionIndex].add 'poison'
            @pieces[@_infectionIndex - 1]?.add 'poison'

        _checkSnakeAt: (square) ->

            return unless square.has 'snake'

            for piece, index in @pieces

                if piece.position.equals square.position

                    if piece.has 'poison'
                        @_infectionIndex -= index
                    else
                        @_resetInfection()

                    @_splitAt index
                    return

                piece.status = 'dead'

        _splitAt: (index) ->

            return unless index and index > 0

            @pieces = @pieces.slice index
            @_length -= index
            @_score.sub index, true

        _checkFoodAt: (square) ->

            if square.has 'food'
                @_score.add()
                @_length += 1
            else
                @tail.off()
                @pieces.shift()

            square.remove 'food'

        _checkPoisonAt: (square) ->

            return unless square.has('poison') and @_length > Const.snakeMinLength

            @_infected = true

            square.remove 'poison'

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
            prevDirectionVec = @_directionVec

            if @_directionQueue.length
                prevDirectionVec = @_directionQueue[@_directionQueue.length - 1]?[1]

            if newDirectionVec.dot(prevDirectionVec) is 0
            
                @_nextHead = @head.neighbours[newDirectionVec]
                @_directionQueue.push [direction, newDirectionVec]
