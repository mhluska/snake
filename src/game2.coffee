define [
    
    'jquery'
    'src/game'
    'src/grid'
    'src/graphics2'

    ], ($, Game, Grid, Graphics2) ->

    class Game2 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            @maxFood = 4

            # TODO: Load stylesheet only if were using DOM
            @grid = new Grid @

            @graphics = new Graphics2 @, @grid, $(selector).eq(0)
            @_startGame()

