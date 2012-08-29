define [
    
    'jquery'
    'src/utils'
    'src/queue'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Queue, Vector3, Const) ->

    class Snake

        constructor: (@_faces, @_food, @_score) ->
            
            @_orientation =
                up:    Const.normalY.clone()
                right: Const.normalX.clone()
                down:  Const.normalNegY.clone()
                left:  Const.normalNegX.clone()

            @_length = 5

            @_resetInfection()

            @_playing = false
            @_direction = 'up'
            @_directionVec = @_orientation[@_direction]

            @_setupControls()

            @moves = new Queue

            middle = (Const.squareCount - 1) / 2
            startFace = @_faces[Const.startFaceIndex]
            @pieces = (startFace.squares[middle][i] for i in [0...@_length])

            @head = @pieces[@_length - 1]
            @prevHead = @pieces[@_length - 2]
            @tail = @pieces[0]

            piece.on() for piece in @pieces

        acceptingPath: ->

            @moves.isEmpty() and not @_playing

        onNewFace: ->

            not @head.adjacentTo @prevHead

        move: ->
            
            @_setNextDirection() if @moves.length()

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

            if @onNewFace()

                directionVecBack = @prevHead.face.normal.clone()
                @_directionVec = directionVecBack.clone().negate()

                @_orientation[@_direction] = @_directionVec
                @_orientation[Utils.opposite @_direction] = directionVecBack

        _setNextDirection: ->

            nextSquare = @moves.dequeue()

            for own direction, square of @head.neighbours
                if square.position.equals nextSquare.position
                    @_directionVec = direction
                    break

            for own direction, vector of @_orientation
                if vector.equals @_directionVec
                    @_direction = direction
                    break

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

            @_food.remove square

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
            if @_infectionIndex is endIndex + 1
                @_resetInfection()
                @_chainKill @_splitAt endIndex - 1
                return

            @pieces[@_infectionIndex].status = 'poisoned'
            @pieces[@_infectionIndex - 1]?.status = 'poisoned'

        _chainKill: (squares) ->

            index = 0

            do kill = ->

                return if index is squares.length
                squares[index++].status = 'dead'
                setTimeout kill, 25

        _splitAt: (index) ->

            # The non-zero check prevents constantly eating the snake tail.
            return unless index and index > 0

            @_length -= index
            @_score.sub index, true
            @pieces.splice 1, index

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                # TODO: Get player controls working with AI.
                return
                switch event.keyCode
                    when 37 then @_turn 'left'
                    when 38 then @_turn 'up'
                    when 39 then @_turn 'right'
                    when 40 then @_turn 'down'
                    else return

        _turn: (direction) ->

            vector = @_orientation[direction]

            if vector.dot(@_lastQueuedVector or @_directionVec) is 0

                @_lastQueuedVector = vector.clone()
                lastSquare = @moves.last() or @head
                @moves.enqueue lastSquare.neighbours[vector]
