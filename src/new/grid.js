(function() {

  if (window.Game == null) window.Game = {};

  Game.Grid = (function() {

    function Grid(snake, graphics) {
      this.snake = snake;
      this.graphics = graphics;
      this.snake.grid = this;
    }

    return Grid;

  })();

}).call(this);
