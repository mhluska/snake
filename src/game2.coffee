define [
    
    'jquery'
    'src/game'
    'src/grid'
    'src/foodqueue'
    'src/graphics2'

    ], ($, Game, Grid, FoodQueue, Graphics2) ->

    class Game2 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            # TODO: Load stylesheet only if were using DOM
            @grid = new Grid @

            maxFood = 4
            @foodItems = new FoodQueue @grid, maxFood

            @graphics = new Graphics2 @, @grid, $(selector).eq(0)
            @_startGame()

