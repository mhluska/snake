'import require-jquery'

class window.TestCube extends Test

    @before: (start) ->

        require ['src/game3'], (@Game) =>

            linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
            $('head').append linkHtml
            $('body').prepend '<div id="game"></div>'

            start()

    @after: (start) ->
        $('#game').remove()
        $('link').last().remove()
        start()

    testMakeCube: ->

        game = new TestCube.Game '#game', debugStep: true

        @show game.grid._world, 'Faces:'
        @assert game.grid._world

        @show game.grid.cubeGraph, 'Face graph:'
        @assert game.grid.cubeGraph

    testGameStep: ->

        game = new TestCube.Game '#game', debugStep: true
        game._gameLoop()
