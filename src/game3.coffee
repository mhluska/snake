define [
    
    'game'
    'cube'
    'utils'
    'graphics3'

    ], (Game, Cube, Utils, Graphics3) ->

    class Game3 extends Game

        constructor: (selector, settings = {}) ->

            super selector, settings
            
            @cube = new Cube @

            @maxFood = 24
            @foodItems = null

            @graphics = new Graphics3 @, @cube
            @_startGame()

        dropFood: ->

            # Drop the food on a random face
            index = Utils.randInt 0, 5
            @cube.faces[index].dropFood()
