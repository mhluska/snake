'import https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'
'import game'
'import queue'
'import snake'
'import grid'
'import graphics'
'import pair'
'import vector2'

class window.TestGrid extends Test

    # Setup a game
    @before: ->

        linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
        $('head').append linkHtml
        @game = new SNAKE.Game debugStep: true

    before: ->

        @game = TestGrid.game
        @snake = @game.snake
        @grid = @game.grid

    setupFood: (coordsArray) ->

        @game.restart()

        # Remove the first randomly-generated food item
        @game._gameLoop()
        @grid.foodItems.dequeue()

        # Drop a few pieces of food
        for coords in coordsArray
            foodPos = new SNAKE.Pair coords[0], coords[1]
            @grid.dropFood foodPos

        @game._gameLoop()

    testClosestFood: ->

        @setupFood [
            [@grid.squaresX - 1, @grid.squaresY - 1]
            [0, 0]
            [4, 6]
        ]

        closestFood = @grid.closestFood @game.snake.head
        @show "Closest food item: #{closestFood.toString()}"

        @assert closestFood.equals new SNAKE.Pair 4, 6

    testClosestFoodWrap: ->

        @setupFood [
            [@grid.squaresX - 1, @grid.squaresY - 1]
            [0, 0]
            [@grid.squaresX - 1, 6]
        ]

        closestFood = @grid.closestFood @game.snake.head
        @show "Closest food item: #{closestFood.toString()}"

        @assert closestFood.equals new SNAKE.Pair @grid.squaresX - 1, 6
    testModuloBoundaries: ->
        console.log 'doing test modulo boundaries!'

