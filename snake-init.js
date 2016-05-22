(function () {
  window.snakeGameLoaded = function(SnakeGame) {
    var game = new SnakeGame(document.querySelector('.snake-game'));
    game.run();
  };
})();
