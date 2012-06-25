window.Game ?= {}
class Game.Graphics

    constructor: (@grid, @graphicsType = 'dom') ->

       @grid.setup @
       @buildDOM() if @graphicsType is 'dom'

    setNodePosition: (node, x, y) ->

        return unless node

        offset = @dom.grid.offset()
        node.css
            top: offset.top + y * @grid.squareHeight
            left: offset.left + x * @grid.squareWidth

        node.show()

    update: ->
        for column, x in @grid.world
            for square, y in column 
                @setNodePosition square.snake.node, x, y if square.snake

    buildDOMElem: (x, y, type) ->

        elem =
            x: x, y: y,
            node: $("<div class='#{type}'></div>")

        @setNodePosition elem.node, elem.x, elem.y
        elem.node.css
            width: @grid.squareWidth
            height: @grid.squareHeight

        elem

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
                elem = @buildDOMElem x, y, type
                square[type] = elem

                @dom.squares.push elem
                @dom.grid.append elem.node
                


                

