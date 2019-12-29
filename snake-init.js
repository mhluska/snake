(function () {
  window.snakeGameLoaded = function(SnakeGame) {
    const isMobile = typeof window.orientation !== 'undefined';
    const game = new SnakeGame(document.querySelector('.snake-game'), {
      keys: true,
      enemies: isMobile ? 1 : 5,
      zoom: isMobile ? 1 : 1.25
    });

    game.run();
  };
})();
