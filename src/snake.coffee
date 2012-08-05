define ['jquery', 'src/utils'], ($, Utils) ->

    # TODO: Don't use jQuery. Get a small library for controls
    class Snake

        constructor: (@_faces) ->

            @_length = 5
            @_direction = 'up'

            @_setupControls()

            @pieces = (@_faces[2].squares[0][index] for index in [0...@_length])
            @head = @pieces[@pieces.length - 1]
            @tail = @pieces[0]

            piece.status = 'on' for piece in @pieces

        move: ->

            @tail.status = 'off'

            newHead = @head.neighbours[@_direction]
            @pieces.push newHead
            @pieces.shift()

            @tail = @pieces[0]
            @head = newHead
            @head.status = 'on'

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
