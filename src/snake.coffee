define ['jquery', 'src/utils', 'src/constants'], ($, Utils, Const) ->

    class Snake

        constructor: (@_faces) ->

            @_length = 5
            @_direction = 'up'

            @_setupControls()

            startFace = @_faces[Const.startFaceIndex]
            @pieces = (startFace.squares[0][index] for index in [0...@_length])
            @head = @pieces[@_length - 1]
            @prevHead = @pieces[@_length - 2]
            @tail = @pieces[0]

            piece.status = 'on' for piece in @pieces

            $(window).keydown (event) =>
                @move() if event.keyCode is 84

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
                @_direction = Utils.opposite @head.face.directionTo @prevHead.face

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                newDirection = @_direction
                switch event.keyCode
                    when 37 then newDirection = 'left'
                    when 38 then newDirection = 'up'
                    when 39 then newDirection = 'right'
                    when 40 then newDirection = 'down'
                    else return

                unless @_direction is Utils.opposite newDirection
                    @_direction = newDirection
