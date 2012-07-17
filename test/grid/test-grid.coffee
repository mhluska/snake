'import https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'
'import game'
'import queue'
'import snake'
'import grid'
'import graphics'
'import pair'

class window.TestGrid extends Test

    # Setup a game
    @before: ->

        linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
        $('head').append linkHtml
        @game = new SNAKE.Game debugStep: true

    testClosestFood: ->
        TestGrid.game.grid.dropFood()
        TestGrid.game.grid.dropFood()
        TestGrid.game.grid.dropFood()
        TestGrid.game._gameLoop()
        console.log 'doing test closest food!'

    testModuloBoundaries: ->
        console.log 'doing test modulo boundaries!'

