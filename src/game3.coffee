define [
    
    'game'
    'cube'
    'graphics3'

    ], (Game, Cube, Graphics3) ->

    class Game3 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            @grid = new Cube @

            @graphics = new Graphics3 @, @grid
            @_startGame()

