define [
    
    'src/game'
    'src/cube'
    'src/graphics3'
    'src/foodqueue'

    ], (Game, Cube, Graphics3, FoodQueue) ->

    class Game3 extends Game

        constructor: (id, settings = {}) ->

            super settings

            @grid = new Cube @

            maxFood = 24
            @foodItems = new FoodQueue @grid, maxFood

            @graphics = new Graphics3 @, @grid, document.getElementById id
            @_startGame()

