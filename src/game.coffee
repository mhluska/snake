# TODO: Use the _privateMethod style throughout the whole project
# TODO: Set up ender.js and use it to install keymaster.js and zepto
# TODO: Switch from jQuery to zepto

window.SNAKE ?= {}

class SNAKE.Game

    constructor: (settings) ->

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
        # and registerFoodAt
        @grid.foodCount = 0
        @grid.foodItems = new SNAKE.FoodQueue @grid

        @snake.setup @grid

        @grid.dropFood()

        clearInterval @grid.gameIntervalID

        return @setupGameStep() if @debugStep

        @grid.gameIntervalID = setInterval @_gameLoop, @grid.timeStepRate
        @_gameLoop()

    _gameLoop: ->
        @snake.move()
        @graphics.update()

    setupGameStep: ->
        $(window).keydown (event) =>
            @_gameLoop() if event.keyCode is 83

        console.warn 'Debug stepping is active. Press s to move a time step.'

    log: (message) ->
        return unless @debugPrint
        console.log message


