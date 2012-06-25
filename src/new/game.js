(function() {
  var graphics, grid, run, snake;

  snake = new Game.Snake;

  grid = new Game.Grid(snake);

  graphics = new Game.Graphics(grid);

  run = function() {
    snake.move();
    return graphics.update();
  };

  setInterval(run, 150);

  run();

}).call(this);
