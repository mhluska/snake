(function() {
  var Grid;

  if (window.Game == null) window.Game = {};

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
      this.grid.width(this.squareWidth * this.squaresX);
      this.grid.height(this.squareHeight * this.squaresY);
      square = $('<div class="square"></div>');
      square.width(this.squareWidth).height(this.squareHeight);
      this.activeSquares = this.snake.chain.map(function() {
        return square.clone().appendTo(_this.grid);
      });
      this.grid.insertBefore($('body script').eq(0));
    }

    Grid.prototype.update = function() {
      var index, piece, _len, _ref, _results;
      _ref = this.snake.chain;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        piece = _ref[index];
        _results.push(this.activeSquares[index].css({
          top: piece.y * this.squareHeight + this.grid.offset().top,
          left: piece.x * this.squareWidth + this.grid.offset().left
        }));
      }
      return _results;
    };

    return Grid;

  })();

}).call(this);
