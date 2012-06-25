window.Game ?= {}
class Game.Grid

    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->

        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

        @squareWidth = 15
        @squareHeight = 15
        @squareTypes = ['food', 'snake']

        @snake.setup @

    setup: (graphics) ->
        @graphics = graphics

    isEmptySquare: (square) ->

        for type in @squareTypes
            return false if square[type]

        return true

    registerSquare: (pair, type) -> @world[pair.x][pair.y][type] = true
