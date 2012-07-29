define [
    
    'game'
    'grid'
    'utils'
    'graphics2'

    ], (Game, Grid, Utils, Graphics2) ->

    class Game2 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            # TODO: Load stylesheet only if were using DOM
            @grid = new Grid @

            @maxFood = 4
            @foodItems = null

            @graphics = new Graphics2 @, @grid, $(selector).eq(0)
            @_startGame()

        dropFood: (pos) =>

            pos ?= Utils.randPair @grid.squaresX - 1, @grid.squaresY - 1
            @foodItems.enqueue pos
            @foodItems.dequeue() if @foodCount > @maxFood


