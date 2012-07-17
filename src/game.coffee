# TODO: Use the _privateMethod style throughout the whole project
# TODO: Set up ender.js and use it to install keymaster.js and zepto
# TODO: Switch from jQuery to zepto

window.SNAKE ?= {}

class SNAKE.Game

    constructor: (settings = {}) ->

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

        @snake = new SNAKE.Snake @
        @grid = new SNAKE.Grid @, @snake
        @graphics = new SNAKE.Graphics @, @grid

        @_startGame()

    _startGame: ->
        # Don't modify foodCount manually. This is handled by unregisterFoodAt 
        # and registerFoodAt in grid
        @grid.foodCount = 0
        @grid.foodItems = new SNAKE.FoodQueue @grid

        @snake.setup @grid

        @stepCount = 0

        return @setupGameStep() if @debugStep

        clearInterval @gameIntervalID
        @gameIntervalID = setInterval @_gameLoop, @timeStepRate
        @_gameLoop()

    _gameLoop: =>

        @grid.dropFood() if (@stepCount % @stepsPerFood) is 0

        @snake.move()
        @graphics.update()

        @stepCount += 1

    restart: ->
        @snake = @grid.snake = new SNAKE.Snake @
        @grid.makeWorld()
        @_startGame()

    setupGameStep: ->
        $(window).keydown (event) =>
            @_gameLoop() if event.keyCode is 83

        console.warn 'Debug stepping is active. Press s to move a time step.'

    log: (message) ->
        return unless @debugPrint
        console.log message


