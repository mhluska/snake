window.Game ?= {}
Game.Grid = class Grid
    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->
    
        @snake.cage @squaresX, @squaresY
    
        @grid = $('<div id="grid"></div>')
        
        @squareWidth = 15
        @squareHeight = 15
        
        @grid.width @squareWidth * @squaresX
        @grid.height @squareHeight * @squaresY
        
        square = $('<div class="square"></div>')
        square.width(@squareWidth).height(@squareHeight)

        @activeSquares = @snake.chain.map => square.clone().appendTo @grid
        
        @grid.insertBefore $('body script').eq(0)
        
    update: ->
        for piece, index in @snake.chain
            @activeSquares[index].css
                top: piece.y * @squareHeight + @grid.offset().top
                left: piece.x * @squareWidth + @grid.offset().left

