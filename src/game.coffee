# TODO: Use the _privateMethod style throughout the whole project
# TODO: Set up ender.js and use it to install keymaster.js and zepto
# TODO: Switch from jQuery to zepto
class window.Game

    @debugPrint: false
    @debugStep: false

    @log: (message) ->
        return unless Game.debugPrint
        console.log message
