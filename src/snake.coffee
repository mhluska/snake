define [
    
    'jquery'
    'src/utils'
    'src/queue'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Queue, Vector3, Const) ->

    class Snake

        constructor: (@_faces, @_score) ->
            
            @_orientation =
                up:    Const.normalY.clone()
                right: Const.normalX.clone()
                down:  Const.normalNegY.clone()
                left:  Const.normalNegX.clone()

            @_length = 5

            @_resetInfection()

            @_direction = 'up'
            @_directionVec = @_orientation[@_direction]
            @_moves = new Queue

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

            [@_direction, @_directionVec] = @_moves.dequeue() if @_moves.length()

            newHead = @head.neighbours[@_directionVec]
            @pieces.push newHead

            switch newHead.item

                when 'snake' then @_eatSnakeAt newHead
                when 'poison' then @_eatPoisonAt newHead
                when 'food' then @_eatFoodAt newHead

            @tail?.off()
            @pieces.shift()
            @tail = @pieces[0]
            @prevHead = @head
            @head = newHead
            @head.on()

            @_growInfection() if @_infected

            # The snake has entered a new face.
            if @onNewFace()

                directionVecBack = @prevHead.face.normal.clone()
                @_directionVec = directionVecBack.clone().negate()

                @_orientation[@_direction] = @_directionVec
                @_orientation[Utils.opposite @_direction] = directionVecBack

        _eatSnakeAt: (square) ->

            return if square.status is 'dead'

            for piece, index in @pieces

                prevStatus = piece.status
                piece.status = 'dead'

                if piece.position.equals square.position

                    if prevStatus is 'poisoned'
                        @_infectionIndex -= index
                    else
                        @_resetInfection()

                    @_splitAt index
                    return

        _eatPoisonAt: (square) ->

            return unless @_length > Const.snakeMinLength
            @_infected = true

        _eatFoodAt: (square) ->

            # Add a blank element which the movement algorithm will destroy
            # instead of a real snake piece.
            @pieces.unshift null
            @tail = @pieces[0]

            @_score.add()
            @_length += 1

        _resetInfection: ->
            
            @_infected = false
            @_infectedMoves = 0
            @_infectionIndex = 1

        _growInfection: ->

            @_infectedMoves += 1
            @_infectionIndex += 1 if @_infectedMoves % 10 is 0

            endIndex = @_length - Const.snakeMinLength + 1
            if @_infectionIndex is endIndex
                @_resetInfection()
                @_eatSnakeAt @pieces[endIndex - 1]
                return

            @pieces[@_infectionIndex].status = 'poisoned'
            @pieces[@_infectionIndex - 1]?.status = 'poisoned'

        _splitAt: (index) ->

            # The non-zero check prevents constantly eating the snake tail.
            return unless index and index > 0

            @pieces = @pieces.slice index
            @_length -= index
            @_score.sub index, true

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
            prevDirectionVec = @_moves.peek()?[1] or @_directionVec

            if newDirectionVec.dot(prevDirectionVec) is 0
            
                @_nextHead = @head.neighbours[newDirectionVec]
                @_moves.enqueue [direction, newDirectionVec]
