require.config
    paths:
        'jquery': 'lib/jquery'

    shim:
        'lib/Three.js': 'exports': 'THREE'

require ['src/game'], (Game) ->

    gameWrapper = document.getElementById 'game'
    game = new Game gameWrapper
    game.run()
