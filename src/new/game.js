(function() {
  var graphics, grid, run, snake;

  snake = new Game.Snake;

  graphics = new Game.Graphics;

  grid = new Game.Grid(snake, graphics);

  run = function() {
    snake.move();
    return graphics.update();
  };

  setInterval(run, 150);

  run();

}).call(this);
