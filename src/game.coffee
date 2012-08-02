# TODO: Use the _privateMethod style throughout the whole project
# TODO: Rename grid since it can be a Grid or Cube module

define [

    'jquery'
    'src/snake'
    'src/utils'
    'src/foodqueue'

    ], ($, Snake, Utils, FoodQueue) ->

    class Game

        constructor: (selector, settings = {}) ->
            
            @stepCount = 0
            @stepsPerFood = 20
            @timeStepRate = 100

            @gameIntervalID = null

            defaults =
                debugPrint: false
                debugStep: false

            for option, value of defaults
                @[option] = value
                @[option] = settings[option] if settings[option]

        _startGame: ->

            @grid.makeWorld()
            @snake = new Snake @, @grid

            @stepCount = 0

            return @setupGameStep() if @debugStep

            @gameIntervalID = setInterval @_gameLoop, @timeStepRate
            @_gameLoop()

        _gameLoop: =>

            @_dropFood() if (@stepCount % @stepsPerFood) is 0

            return unless @snake.move()
            @graphics.update()

            @stepCount += 1

        _dropFood: (pos) =>

            pos ?= Utils.randPair @grid.squaresX - 1, @grid.squaresY - 1
            @foodItems.enqueue pos

        restart: ->
            clearInterval @gameIntervalID
            @snake = @grid.snake = new Snake @, @grid
            @foodItems.foodCount = 0
            @grid.destroyWorld()
            @graphics.update()
            @_startGame()
            false

        setupGameStep: ->
            $(window).keydown (event) =>
                @_gameLoop() if event.keyCode is 83

            console.warn 'Debug stepping is active. Press s to move a time step.'

        log: (message) ->
            return unless @debugPrint
            console.log message
