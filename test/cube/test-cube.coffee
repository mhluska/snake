'import game'
'import snake'
'import grid'
'import graph'
'import graphics3'
'import cube'

class window.TestCube extends Test

    @before: ->
        linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />'
        $('head').append linkHtml
        $('body').prepend '<div id="game"></div>'

    testMakeCube: ->

        # TODO: This fails because the Game module uses an asynchronous call to 
        # get the Three.js library
        game = new SNAKE.Game '#game', debugStep: true
        @show game.grid.faces, 'Faces:'

