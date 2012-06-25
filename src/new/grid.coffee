window.Game ?= {}
class Game.Grid

    constructor: (@snake, @squaresX = 25, @squaresY = 15) ->

        @graphics = null

        @world = ( ({} for [0...@squaresY]) for [0...@squaresX] )

        @squareWidth = 15
        @squareHeight = 15

        @snake.setup @

    setup: (graphics) ->
        @graphics = graphics

    moveSquare: (start, end, type) ->
        @world[end.x][end.y][type] = @world[start.x][start.y][type]

    isEmptySquare: (square) ->

        squareTypes = ['food', 'snake']
        for type in squareTypes
            return false if square[type]

        return true

    registerSquare: (pair, type) -> @world[pair.x][pair.y][type] = true
