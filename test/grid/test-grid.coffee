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

        $('head').append  '<link rel="stylesheet" type="text/css" href="../snake.css" />'
        @game = new SNAKE.Game debugStep: true

    testClosestFood: ->
        @.class.game.grid.dropFood()
        @.class.game.grid.dropFood()
        @.class.game.grid.dropFood()
        @.class.game._gameLoop()
        console.log 'doing test closest food!'

    testModuloBoundaries: ->
        console.log 'doing test modulo boundaries!'

