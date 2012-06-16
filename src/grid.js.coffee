window.Game ?= {}
Game.Grid = class Grid
    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->
    
        @snake.cage @squaresX, @squaresY
    
        @grid = $('<div id="grid"></div>')
        
        @squareWidth = 15
        @squareHeight = 15

        @foodDropped = false
        
        @grid.width @squareWidth * @squaresX
        @grid.height @squareHeight * @squaresY
        
        square = @makeSquare 'square'
        @activeSquares = @snake.chain.map => square.clone().appendTo @grid
        
        @grid.insertBefore $('body script').eq(0)

        @food = @makeSquare 'food'
        @grid.append @food
        @dropFood()

    # TODO: This shouldn't be in grid
    randInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    makeSquare: (className) ->
        square = $("<div class='#{className}'></div>")
        square.width(@squareWidth).height(@squareHeight)

    dropFood: ->

        return if @foodDropped

        randX = @randInt 0, @squareWidth - 1
        randY = @randInt 0, @squareHeight - 1

        @food.css
            left: randX * @squareWidth + @grid.offset().left
            top: randY * @squareHeight + @grid.offset().top

        @food.show()

        @foodDropped = true
        
    update: ->
        for piece, index in @snake.chain
            @activeSquares[index].css
                left: piece.x * @squareWidth + @grid.offset().left
                top: piece.y * @squareHeight + @grid.offset().top

        @dropFood()

