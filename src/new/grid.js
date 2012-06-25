(function() {

  if (window.Game == null) window.Game = {};

  Game.Grid = (function() {

    function Grid(snake, graphics, squaresX, squaresY) {
      this.snake = snake;
      this.graphics = graphics;
      this.squaresX = squaresX != null ? squaresX : 25;
      this.squaresY = squaresY != null ? squaresY : 15;
      this.world = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 0, _ref = this.squaresX; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          _results.push((function() {
            var _j, _ref2, _results2;
            _results2 = [];
            for (_j = 0, _ref2 = this.squaresY; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; 0 <= _ref2 ? _j++ : _j--) {
              _results2.push({});
            }
            return _results2;
          }).call(this));
        }
        return _results;
      }).call(this);
      this.squareWidth = 15;
      this.squareHeight = 15;
      this.snake.setup(this);
    }

    return Grid;

  })();

}).call(this);
