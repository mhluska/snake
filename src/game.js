(function() {
  var grid, run, snake;

  snake = new Game.Snake;

  grid = new Game.Grid(snake);

  run = function() {
    snake.move();
    return grid.update();
  };

  setInterval(run, 150);

  run();

}).call(this);
