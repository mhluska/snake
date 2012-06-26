window.Game ?= {}
class Game.Graphics

    constructor: (@grid, @graphicsType = 'dom') ->

       @grid.setup @

       # TODO: Make a DOMGraphics class that extends graphics which has these
       # properties.
       @buildDOM() if @graphicsType is 'dom'
       @nodeRemoveQueue = []

    setNodePosition: (node, pos) ->

        return unless node
        
        offset = @dom.grid.offset()
        node.css
            top: offset.top + pos.y * @grid.squareHeight
            left: offset.left + pos.x * @grid.squareWidth

        node.show()

    update: ->

        @deleteZombieSquares()

        for column, x in @grid.world
            for square, y in column
                pos = new Game.Pair x, y
                for type in @grid.squareTypes

                    # Create a new node for any nodes marked for creation
                    square[type] = @appendDOMNode pos, type if square[type] is true
                    @setNodePosition square[type], pos if square[type]

    deleteZombieSquares: ->
        @deleteSquare @nodeRemoveQueue.pop() while @nodeRemoveQueue.length

    deleteSquare: (square) ->
        square.remove()
        square = null

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

        $('body').append @dom.grid

        for column, x in @grid.world
            for square, y in column

                continue if @grid.isEmptySquare square

                type = 'snake' if square.snake
                type = 'food' if square.food

                # Set a reference to the DOM node in the world data
                pos = new Game.Pair x, y
                square[type] = @appendDOMNode pos, type

