class SNAKE.Graphics

    constructor: (@game, @grid, @graphicsType = 'dom') ->

       @grid.setup @

       # TODO: Make a DOMGraphics class that extends graphics which has these
       # properties.
       @grid.makeWorld()
       @buildDOM() if @graphicsType is 'dom'
       @nodeRemoveQueue = []

    setNodePosition: (node, pos) ->

        return unless node
        
        node.css
            top: pos.y * @grid.squareHeight
            left: pos.x * @grid.squareWidth

        node.show()

    update: ->

        @grid.eachSquare (pos, square) =>
            for type in @grid.squareTypes

                # Create a new node for any nodes marked for creation
                square[type] = @appendDOMNode pos, type if square[type] is true
                @setNodePosition square[type], pos if square[type]

    buildDOMNode: (pos, type) ->

        node = $("<div class='#{type}'></div>")
        node.css
            width: @grid.squareWidth
            height: @grid.squareHeight

        @setNodePosition node, pos

        node

    appendDOMNode: (pos, type) ->

        node = @buildDOMNode pos, type
        node.appendTo @dom.grid

    buildDOM: ->

        @dom = {}
        @dom.grid = $('<div id="grid"></div>')
        @dom.grid.css
            width: @grid.squareWidth * @grid.squaresX
            height: @grid.squareHeight * @grid.squaresY

        $('body').prepend @dom.grid

        @grid.eachSquare (pos, square) =>

            return if @grid.isEmptySquare square

            type = 'snake' if square.snake
            type = 'food' if square.food

            # Set a reference to the DOM node in the world data
            square[type] = @appendDOMNode pos, type

    # TODO: The implementation of this function will depend on drawing mode
    # (DOM, Canvas, WebGL etc.)
    visible: (square) ->
        return false unless square and (square instanceof jQuery)
        $(square).is ':visible'

