(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (window.Game == null) window.Game = {};

  Game.Grid = (function() {

    function Grid(snake, squaresX, squaresY) {
      this.snake = snake;
      this.squaresX = squaresX != null ? squaresX : 25;
      this.squaresY = squaresY != null ? squaresY : 15;
      this.dropFood = __bind(this.dropFood, this);
      this.graphics = null;
      this.gameIntervalID = null;
      this.squareWidth = 15;
      this.squareHeight = 15;
      this.squareTypes = ['food', 'snake'];
      this.maxFood = 4;
      this.foodIndex = 0;
      this.foodItems = [];
      this.foodDropRate = 7000;
      this.foodIntervalID = null;
    }

    Grid.prototype.eachSquare = function(callback) {
      var column, pos, square, x, y, _len, _ref, _results;
      if (!this.world) return;
      _ref = this.world;
      _results = [];
      for (x = 0, _len = _ref.length; x < _len; x++) {
        column = _ref[x];
        _results.push((function() {
          var _len2, _results2;
          _results2 = [];
          for (y = 0, _len2 = column.length; y < _len2; y++) {
            square = column[y];
            pos = new Game.Pair(x, y);
            _results2.push(callback(pos, square));
          }
          return _results2;
        })());
      }
      return _results;
    };

    Grid.prototype.makeWorld = function() {
      var _this = this;
      this.eachSquare(function(pos) {
        return _this.unregisterSquareAt(pos);
      });
      return this.world = (function() {
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
    };

    Grid.prototype.setup = function(graphics) {
      return this.graphics = graphics;
    };

    Grid.prototype.startGame = function() {
      var gameLoop,
        _this = this;
      this.snake.setup(this);
      this.dropFood();
      clearInterval(this.gameIntervalID);
      gameLoop = function() {
        _this.snake.move();
        return _this.graphics.update();
      };
      this.gameIntervalID = setInterval(gameLoop, 150);
      return gameLoop();
    };

    Grid.prototype.moveSquare = function(start, end, type) {
      this.world[end.x][end.y][type] = this.world[start.x][start.y][type];
      return this.world[start.x][start.y][type] = null;
    };

    Grid.prototype.isEmptySquare = function(square) {
      var type, _i, _len, _ref;
      _ref = this.squareTypes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        if (square[type]) return false;
      }
      return true;
    };

    Grid.prototype.registerSquare = function(pair, type) {
      return this.world[pair.x][pair.y][type] = true;
    };

    Grid.prototype.unregisterSquareAt = function(pos, types) {
      var type, _i, _len, _ref, _results;
      types = types ? [types] : this.squareTypes;
      _results = [];
      for (_i = 0, _len = types.length; _i < _len; _i++) {
        type = types[_i];
        if ((_ref = this.world[pos.x][pos.y][type]) != null) _ref.hide();
        _results.push(this.world[pos.x][pos.y][type] = null);
      }
      return _results;
    };

    Grid.prototype.hasType = function(type, pos) {
      return this.world[pos.x][pos.y][type] != null;
    };

    Grid.prototype.randInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };

    Grid.prototype.randPair = function(min1, max1, min2, max2) {
      var randX, randY;
      if (arguments.length === 2) {
        randX = this.randInt(0, min1);
        randY = this.randInt(0, max1);
      } else {
        randX = this.randInt(min1, max1);
        randY = this.randInt(min2, max2);
      }
      return new Game.Pair(randX, randY);
    };

    Grid.prototype.resetFoodInterval = function() {
      clearInterval(this.foodIntervalID);
      return this.foodIntervalID = setInterval(this.dropFood, this.foodDropRate);
    };

    Grid.prototype.dropFood = function() {
      var food, item, newFood;
      this.resetFoodInterval();
      if (this.foodItems.length !== this.maxFood) {
        item = this.randPair(this.squaresX - 1, this.squaresY - 1);
        this.foodItems.push(item);
        this.registerSquare(item, 'food');
        return;
      }
      food = this.foodItems[this.foodIndex];
      newFood = this.randPair(this.squaresX - 1, this.squaresY - 1);
      this.moveSquare(food, newFood, 'food');
      this.foodItems[this.foodIndex].copy(newFood);
      return this.foodIndex = (this.foodIndex + 1) % this.maxFood;
    };

    Grid.prototype.restart = function() {
      this.snake = new Game.Snake;
      this.makeWorld();
      return this.startGame();
    };

    return Grid;

  })();

}).call(this);
