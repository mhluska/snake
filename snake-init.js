(function () {
  window.snakeGameLoaded = function(SnakeGame) {
    var game = new SnakeGame(document.querySelector('.snake-game'), { keys: true });
    game.run();
  };
})();
