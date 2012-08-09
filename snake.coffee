require ['src/game'], (Game) ->

    gameWrapper = document.getElementById 'game'
    game = new Game gameWrapper
    game.run()
