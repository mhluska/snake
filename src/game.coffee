# TODO: Use the _privateMethod style throughout the whole project
class window.Game
    @debug: false
    @log: (message) ->
        return unless Game.debug
        console.log message
