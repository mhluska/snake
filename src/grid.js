(function() {
  var Grid, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if ((_ref = window.Game) == null) {
    window.Game = {};
  }

  Game.Grid = Grid = (function() {

    function Grid(snake, squaresX, squaresY) {
      var _this = this;
      this.snake = snake;
      this.squaresX = squaresX != null ? squaresX : 25;
      this.squaresY = squaresY != null ? squaresY : 15;
      this.dropFood = __bind(this.dropFood, this);

      this.snake.cage(this.squaresX, this.squaresY);
      this.gridData = (function() {
        var _i, _ref1, _results;
        _results = [];
        for (_i = 0, _ref1 = this.squaresX; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; 0 <= _ref1 ? _i++ : _i--) {
          _results.push((function() {
            var _j, _ref2, _results1;
            _results1 = [];
            for (_j = 0, _ref2 = this.squaresY; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; 0 <= _ref2 ? _j++ : _j--) {
              _results1.push({});
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }).call(this);
      this.grid = $('<div id="grid"></div>');
      this.squareWidth = 15;
      this.squareHeight = 15;
      this.grid.width(this.squareWidth * this.squaresX);
      this.grid.height(this.squareHeight * this.squaresY);
      this.snakeSquares = this.snake.chain.map(function(piece) {
        return _this.makeSquare('snake', piece.x, piece.y);
      });
      this.grid.insertBefore($('body script').eq(0));
      this.maxFood = 4;
      this.foodQueue = this.makeFoodQueue(this.maxFood);
      this.foodDropRate = 10000;
      this.foodIntervalID = null;
      this.dropFood();
    }

    Grid.prototype.resetFoodInterval = function() {
      clearInterval(this.foodIntervalID);
      return this.foodIntervalID = setInterval(this.dropFood, this.foodDropRate);
    };

    Grid.prototype.makeFoodQueue = function(maxFood) {
      var queue, _i;
      queue = [];
      for (_i = 0; 0 <= maxFood ? _i < maxFood : _i > maxFood; 0 <= maxFood ? _i++ : _i--) {
        queue.push(this.makeSquare('food'));
      }
      return queue;
    };

    Grid.prototype.randInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };

    Grid.prototype.moveToBack = function(queue, item) {
      var queueIndex;
      queueIndex = queue.indexOf(item);
      this.foodQueue.splice(1, queueIndex);
      return this.foodQueue.unshift(item);
    };

    Grid.prototype.makeSquare = function(type, x, y) {
      var square;
      if (x == null) {
        x = null;
      }
      if (y == null) {
        y = null;
      }
      square = $("<div class='" + type + "'></div>");
      square.type = type;
      square.x = x;
      square.y = y;
      square.width(this.squareWidth).height(this.squareHeight);
      return square.appendTo(this.grid);
    };

    Grid.prototype.moveSquare = function(square, x, y) {
      if (square.x && square.y) {
        this.gridData[square.x][square.y][square.type] = null;
      }
      this.gridData[x][y][square.type] = square;
      square.css({
        left: x * this.squareWidth + this.grid.offset().left,
        top: y * this.squareHeight + this.grid.offset().top
      });
      return square.show();
    };

    Grid.prototype.dropFood = function() {
      var foodItem, randX, randY;
      if (!this.foodQueue.length) {
        return;
      }
      randX = this.randInt(0, this.squareWidth - 1);
      randY = this.randInt(0, this.squareHeight - 1);
      foodItem = this.foodQueue.pop();
      this.foodQueue.unshift(foodItem);
      this.moveSquare(foodItem, randX, randY);
      return this.resetFoodInterval();
    };

    Grid.prototype.update = function() {
      var index, piece, _i, _len, _ref1, _results;
      this.feedSnake();
      _ref1 = this.snake.chain;
      _results = [];
      for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
        piece = _ref1[index];
        _results.push(this.moveSquare(this.snakeSquares[index], piece.x, piece.y));
      }
      return _results;
    };

    Grid.prototype.feedSnake = function(food) {
      var head, position;
      head = this.snake.chain[0];
      if (this.gridData[head.x][head.y].snake) {
        this.restart();
      }
      food = this.gridData[head.x][head.y].food;
      if (!food) {
        return;
      }
      food.hide();
      this.moveToBack(this.foodQueue, food);
      this.gridData[head.x][head.y].food = null;
      position = this.snake.grow();
      this.snakeSquares.push(this.makeSquare('snake', position.x, position.y));
      return this.dropFood();
    };

    Grid.prototype.restart = function() {
      return console.log('restarting');
    };

    return Grid;

  })();

}).call(this);
