define ->

    class Piece

        @states: visible: 0, hidden: 1

        constructor: (@node = null, @type = 'food', @state = null) ->

            @state ?= Piece.states.hidden

        show: -> @state = Piece.states.visible

        visible: -> @state is Piece.states.visible

        hide: -> @state = Piece.states.hidden

        hidden: -> @state is Piece.states.hidden

        exists: -> @node?
