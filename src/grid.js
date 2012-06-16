(function() {
  var Grid, _ref;

  if ((_ref = window.Game) == null) {
    window.Game = {};
  }

  Game.Grid = Grid = (function() {

    function Grid(snake, squaresX, squaresY) {
      var square,
        _this = this;
      this.snake = snake;
      this.squaresX = squaresX != null ? squaresX : 25;
      this.squaresY = squaresY != null ? squaresY : 15;
      this.snake.cage(this.squaresX, this.squaresY);
      this.grid = $('<div id="grid"></div>');
      this.squareWidth = 15;
      this.squareHeight = 15;
      this.foodDropped = false;
      this.grid.width(this.squareWidth * this.squaresX);
      this.grid.height(this.squareHeight * this.squaresY);
      square = this.makeSquare('square');
      this.activeSquares = this.snake.chain.map(function() {
        return square.clone().appendTo(_this.grid);
      });
      this.grid.insertBefore($('body script').eq(0));
      this.food = this.makeSquare('food');
      this.grid.append(this.food);
      this.dropFood();
    }

    Grid.prototype.randInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };

    Grid.prototype.makeSquare = function(className) {
      var square;
      square = $("<div class='" + className + "'></div>");
      return square.width(this.squareWidth).height(this.squareHeight);
    };

    Grid.prototype.dropFood = function() {
      var randX, randY;
      if (this.foodDropped) {
        return;
      }
      randX = this.randInt(0, this.squareWidth - 1);
      randY = this.randInt(0, this.squareHeight - 1);
      this.food.css({
        left: randX * this.squareWidth + this.grid.offset().left,
        top: randY * this.squareHeight + this.grid.offset().top
      });
      this.food.show();
      return this.foodDropped = true;
    };

    Grid.prototype.update = function() {
      var index, piece, _i, _len, _ref1;
      _ref1 = this.snake.chain;
      for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
        piece = _ref1[index];
        this.activeSquares[index].css({
          left: piece.x * this.squareWidth + this.grid.offset().left,
          top: piece.y * this.squareHeight + this.grid.offset().top
        });
      }
      return this.dropFood();
    };

    return Grid;

  })();

}).call(this);
