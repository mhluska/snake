# TODO: Use the _privateMethod style throughout the whole project
# TODO: Rename grid since it can be a Grid or Cube module

define [

    'snake'
    'grid'
    'foodqueue'

    ], (Snake, Grid, FoodQueue) ->

    class Game

        constructor: (selector, settings = {}) ->
            
            @stepCount = 0
            @foodCount = 0
            @stepsPerFood = 20
            @timeStepRate = 100

            # These are set by subclasses
            @grid = null
            @graphics = null
            @foodItems = null

            @gameIntervalID = null

            defaults =
                debugPrint: false
                debugStep: false

            for option, value of defaults
                @[option] = value
                @[option] = settings[option] if settings[option]

            @snake = new Snake @

        _startGame: ->
            # Don't modify foodCount manually. This is handled by unregisterFoodAt 
            # and registerFoodAt in grid
            @foodCount = 0
            @foodItems = new FoodQueue @grid

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

        visibleFood: ->

            # TODO: This is kind of cheating: accessing the array 
            # implementation underneath the queue. Use the more general linked 
            # list as an implementation so that you can iterate it and still 
            # have O(1) enqueue and dequeue
            foodPositions = []
            for foodPos in @foodItems._queue
                if @graphics.entityIsVisible @grid.squareAt(foodPos).food
                    foodPositions.push foodPos
            
            foodPositions

        restart: ->
            @snake = @grid.snake = new Snake @
            @grid.makeWorld()
            @_startGame()

        setupGameStep: ->
            $(window).keydown (event) =>
                @_gameLoop() if event.keyCode is 83

            console.warn 'Debug stepping is active. Press s to move a time step.'

        log: (message) ->
            return unless @debugPrint
            console.log message
