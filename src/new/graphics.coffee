window.Game ?= {}
class Game.Graphics

    constructor: (@grid, @graphicsType = 'dom') ->

       @grid.setup @
       @buildDOM() if @graphicsType is 'dom'

    setNodePosition: (node, pos) ->

        return unless node
        
        offset = @dom.grid.offset()
        node.css
            top: offset.top + pos.y * @grid.squareHeight
            left: offset.left + pos.x * @grid.squareWidth

        node.show()

    update: ->
        for column, x in @grid.world
            for square, y in column
                pos = new Game.Pair x, y
                for type in @grid.squareTypes

                    # Create a new node for any nodes marked for creation
                    if @grid.isRegistered square[type]
                        square[type] = @appendDOMNode pos, type
                        return

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
        @dom.squares.push node
        node.appendTo @dom.grid

    buildDOM: ->

        @dom = {}
        @dom.grid = $('<div id="grid"></div>')
        @dom.grid.css
            width: @grid.squareWidth * @grid.squaresX
            height: @grid.squareHeight * @grid.squaresY

        $('body').append @dom.grid

        @dom.squares = []
        for column, x in @grid.world
            for square, y in column

                continue if @grid.isEmptySquare square

                type = 'snake' if square.snake
                type = 'food' if square.food

                # Set a reference to the DOM node in the world data
                pos = new Game.Pair x, y
                square[type] = @appendDOMNode pos, type

