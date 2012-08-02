# TODO: Use the _privateMethod style throughout the whole project
# TODO: Rename grid since it can be a Grid or Cube module

define [

    'jquery'
    'src/snake'
    'src/foodqueue'

    ], ($, Snake, FoodQueue) ->

    class Game

        constructor: (selector, settings = {}) ->
            
            @foodCount = 0
            @stepCount = 0
            @stepsPerFood = 20
            @timeStepRate = 100

            # These are set by subclasses
            @grid = null
            @graphics = null

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

            @foodCount = 0
            @foodItems = new FoodQueue @grid

            @stepCount = 0

            return @setupGameStep() if @debugStep

            @gameIntervalID = setInterval @_gameLoop, @timeStepRate
            @_gameLoop()

        _gameLoop: =>

            @grid.dropFood() if (@stepCount % @stepsPerFood) is 0

            return unless @snake.move()
            @graphics.update()

            @stepCount += 1

        restart: ->
            clearInterval @gameIntervalID
            @snake = @grid.snake = new Snake @, @grid
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
