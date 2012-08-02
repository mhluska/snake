define [
    
    'src/game'
    'src/cube'
    'src/graphics3'

    ], (Game, Cube, Graphics3) ->

    class Game3 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings

            @grid = new Cube @
            maxFood = 24
            @foodItems = new FoodQueue @grid, maxFood

            @graphics = new Graphics3 @, @grid
            @_startGame()

