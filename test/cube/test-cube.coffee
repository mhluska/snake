'import require-jquery'

class window.TestCube extends Test

    @before: (start) ->

        require ['src/game'], (@Game) =>

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
        # @show game.grid.faces, 'Faces:'

