(function () {
  window.snakeGameLoaded = function(SnakeGame) {
    var isMobile = typeof window.orientation !== 'undefined';
    var game = new SnakeGame(document.querySelector('.snake-game'), {
      keys: true,
      enemies: isMobile ? 1 : 5
    });

    game.run();
  };
})();
