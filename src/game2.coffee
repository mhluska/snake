define [
    
    'game'
    'grid'
    'graphics2'

    ], (Game, Grid, Graphics2) ->

    class Game2 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            # TODO: Load stylesheet only if were using DOM
            @grid = new Grid @

            @graphics = new Graphics2 @, @grid, $(selector).eq(0)
            @_startGame()

