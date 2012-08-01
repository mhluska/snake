require.config
    paths:
        'jquery': 'lib/jquery'

require ['jquery', 'src/game2'], ($, Game2) ->
    new Game2 '#game'
