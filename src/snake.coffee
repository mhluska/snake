define [
    
    'jquery'
    'src/utils'
    'src/queue'
    'src/vector3'
    'src/constants'

    ], ($, Utils, Queue, Vector3, Const) ->

    class Snake

        constructor: (@_faces, @_edible, @_score) ->
            
            @_orientation =
                up:    Const.normalY.clone()
                right: Const.normalX.clone()
                down:  Const.normalNegY.clone()
                left:  Const.normalNegX.clone()

            @_length = Const.snakeMinLength

            @_resetInfection()

            @_direction = 'up'
            @_lastDirection = @_direction
            @_directionVec = @_orientation[@_direction]

            @moves = new Queue

            middle = Math.round (Const.squareCount - 1) / 2
            startFace = @_faces[Const.startFaceIndex]
            @pieces = (startFace.squares[middle][i] for i in [0...@_length])

            @head = @pieces[@_length - 1]
            @prevHead = @pieces[@_length - 2]
            @tail = @pieces[0]

            piece.on() for piece in @pieces

        onNewFace: ->

            @head.face isnt @prevHead.face

        turn: (direction) ->

            return if direction is Utils.opposite @_lastDirection

            # TODO: Implement queueing of moves across faces. Is it worth
            # the code complexity?
            lastSquare = @moves.last() or @head
            return if lastSquare.face isnt @head.face

            @_lastDirection = direction

            directionVector = @_orientation[direction]
            @moves.enqueue lastSquare.neighbours[directionVector]

        die: ->

            endIndex = @_length - Const.snakeMinLength
            @_chainKill @_splitAt endIndex

        move: ->

            @_setDirection @moves.dequeue()
            
            newHead = @head.neighbours[@_directionVec]

            @_orient() if newHead.face isnt @head.face

            switch newHead.item

                when 'snake' then @_eatSnakeAt newHead
                when 'poison' then @_eatPoisonAt newHead
                when 'food' then @_eatFoodAt newHead

            @tail?.off()
            @pieces.shift()
            @pieces.push newHead
            @tail = @pieces[0]
            @prevHead = @head
            @head = newHead
            @head.on()

            @_growInfection() if @_infected

        _setDirection: (nextSquare) ->

            return unless nextSquare

            for own direction, square of @head.neighbours
                if square.position.equals nextSquare.position
                    @_directionVec = direction
                    break

            for own direction, vector of @_orientation
                if vector.toString() is @_directionVec
                    @_direction = direction
                    @_lastDirection = direction
                    break

        _orient: ->

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

            @_edible.poison.remove square

            return unless @_length > Const.snakeMinLength
            @_infected = true

        _eatFoodAt: (square) ->

            @_edible.food.remove square

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

            endIndex = @_length - Const.snakeMinLength
            if @_infectionIndex is endIndex
                @_resetInfection()
                @die()
                return

            @pieces[@_infectionIndex].status = 'poisoned'
            @pieces[@_infectionIndex - 1]?.status = 'poisoned'

        _chainKill: (squares) ->

            return unless squares

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

