window.Game ?= {}
class Game.Grid

    constructor: (@snake, @graphics, @squaresX = 25, @squaresY = 15) ->

        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

        @squareWidth = 15
        @squareHeight = 15

        @snake.setup @
