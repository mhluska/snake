'import require-jquery'

class window.TestGrid extends Test

    # Setup a game
    @before: (start) ->

        require [

            'src/grid'
            'src/game2'
            'src/pair'

        ], (@Grid, @Game, @Pair) =>

            linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
            $('head').append linkHtml
            $('body').prepend '<div id="game"></div>'
            @game = new @Game '#game', useDom: true, debugStep: true

            start()

    @after: (start) ->
        $('#game').remove()
        $('link').last().remove()
        start()

    before: ->

        @game = TestGrid.game
        @snake = @game.snake
        @grid = @game.grid

    setupFood: (coordsArray) ->

        @game.restart()

        # Remove the first randomly-generated food item
        @game._gameLoop()
        @game.foodItems.dequeue()

        # Drop a few pieces of food
        for coords in coordsArray
            foodPos = new TestGrid.Pair coords[0], coords[1]
            @grid.dropFood foodPos

        @game._gameLoop()

    testRestarts: ->

        @game.restart()
        @game._gameLoop()
        @game.foodItems.dequeue()
        @game.dropFood new TestGrid.Pair 5, 5
        @game.dropFood new TestGrid.Pair 5, 6
        @game.dropFood new TestGrid.Pair 5, 6
        @game._gameLoop()
        @game.restart()
        @game.restart()

        @game._gameLoop()
        @game._gameLoop()
        @game.restart()

        @game._gameLoop()
        @game._gameLoop()
        @game._gameLoop()
        @game.restart()

    testClosestFood: ->

        @setupFood [
            [@grid.squaresX - 1, @grid.squaresY - 1]
            [0, 0]
            [4, 6]
        ]

        @game._gameLoop()
        closestFood = @game.snake.moves.back()
        @show "Closest food item: #{closestFood.toString()}"

        @assert closestFood.equals new TestGrid.Pair 4, 6

    testClosestFoodWrap: ->

        @setupFood [
            [@grid.squaresX - 1, @grid.squaresY - 1]
            [0, 0]
            [@grid.squaresX - 1, 6]
        ]

        @game._gameLoop()
        closestFood = @game.snake.moves.back()
        @show "Closest food item: #{closestFood.toString()}"

        @assert closestFood.equals new TestGrid.Pair @grid.squaresX - 1, 6

    testModuloBoundaries: ->
        console.log 'doing test modulo boundaries!'

