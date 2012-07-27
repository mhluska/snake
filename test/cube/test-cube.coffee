'import require-jquery'

class window.TestCube extends Test

    @before: ->
        linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
        $('head').append linkHtml
        $('body').prepend '<div id="game"></div>'

    testMakeCube: ->

        game = new SNAKE.Game '#game', debugStep: true
        @show game.grid.faces, 'Faces:'

