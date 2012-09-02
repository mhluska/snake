gameWrapper = document.getElementById 'game'

detector = new Detector
unless detector.webgl

    detector.showWebGLError gameWrapper
    return

require ['src/game'], (Game) ->

    game = new Game gameWrapper
    game.run()
