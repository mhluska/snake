window.Game ?= {}
class Game.Graphics

    constructor: (@grid, @graphicsType = 'dom') ->

       @buildDOMElems() if @graphicsType is 'dom'

    update: ->

    buildDOMElems: ->

        @dom = {}
        @dom.grid = $('<div id="grid"></div>')
        @dom.grid.css
            width: @grid.squareWidth * @grid.squaresX
            height: @grid.squareHeight * @grid.squaresY

        @dom.squares = []
        for column, squareX in @grid.world
            for square, squareY in column

                continue if $.isEmptyObject square

                type = 'snake' if square.snake
                type = 'food' if square.food

                elem = x: squareX, y: squareY, type: type
                elem.node = $("<div class='#{type}'></div>")
                elem.node.css x: elem.x, y: elem.y

                @dom.squares.push elem
                @dom.grid.append elem.node

        $('body').append @dom.grid
                


                

