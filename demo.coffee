requirejs.config
    baseUrl: 'src'

require ['game2'], (Game2) ->
    new Game2 '#game'
