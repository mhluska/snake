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
      this.timeStepRate = 100;
      this.squareWidth = 15;
      this.squareHeight = 15;
      this.squareTypes = ['food', 'snake'];
      this.maxFood = 4;
      this.foodCount = 0;
      this.foodItems = null;
      this.foodDropRate = this.timeStepRate * 20;
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
        return _this.unregisterAllSquaresAt(pos);
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
      this.foodCount = 0;
      this.foodItems = new Game.FoodQueue(this);
      this.snake.setup(this);
      this.dropFood();
      clearInterval(this.gameIntervalID);
      gameLoop = function() {
        _this.snake.move();
        return _this.graphics.update();
      };
      this.gameIntervalID = setInterval(gameLoop, this.timeStepRate);
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

    Grid.prototype.registerSquareAt = function(pos, type) {
      if (this.world[pos.x][pos.y][type]) return false;
      this.world[pos.x][pos.y][type] = true;
      return true;
    };

    Grid.prototype.registerFoodAt = function(pos) {
      if (!this.registerSquareAt(pos, 'food')) return false;
      this.foodCount += 1;
      return true;
    };

    Grid.prototype.unregisterSquareAt = function(pos, type) {
      var _ref;
      if (!this.world[pos.x][pos.y][type]) return false;
      if ((_ref = this.world[pos.x][pos.y][type]) != null) _ref.hide();
      this.world[pos.x][pos.y][type] = null;
      return true;
    };

    Grid.prototype.unregisterFoodAt = function(pos) {
      if (!this.unregisterSquareAt(pos, 'food')) return false;
      this.foodCount -= 1;
      return true;
    };

    Grid.prototype.unregisterAllSquaresAt = function(pos) {
      var type, _i, _len, _ref, _results;
      _ref = this.squareTypes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        _results.push(this.unregisterSquareAt(pos, type));
      }
      return _results;
    };

    Grid.prototype.squareHasType = function(type, pos) {
      return this.world[pos.x][pos.y][type] != null;
    };

    Grid.prototype.squareHasFood = function(pos) {
      return this.squareHasType('food', pos);
    };

    Grid.prototype.resetFoodInterval = function() {
      clearInterval(this.foodIntervalID);
      return this.foodIntervalID = setInterval(this.dropFood, this.foodDropRate);
    };

    Grid.prototype.dropFood = function() {
      this.resetFoodInterval();
      this.foodItems.enqueue(Game.Utils.randPair(this.squaresX - 1, this.squaresY - 1));
      if (this.foodCount > this.maxFood) return this.foodItems.dequeue();
    };

    Grid.prototype.restart = function() {
      this.snake = new Game.Snake;
      this.makeWorld();
      return this.startGame();
    };

    Grid.prototype.toGraph = function() {
      var graphEdges;
      graphEdges = [];
      this.eachSquare(function(pos) {
        return this.graphEdges.concat(this._squareToGraphEdges(this, pos));
      });
      return graphEdges;
    };

    Grid.prototype._squareToGraphEdges = function(grid, pos) {
      var edges, square, squareBottomY, squareLeftX, squares, _i, _len;
      if (grid.squareHasType('snake', pos)) return;
      if (this.vertexCount == null) this.vertexCount = 0;
      squareBottomY = pos.y === 0 ? this.squaresY - 1 : pos.x - 1;
      squareLeftX = pos.x === 0 ? this.squaresX - 1 : pos.x - 1;
      squares = [Game.Pair(pos.x, pos.y + 1 % this.squaresY), Game.Pair(pos.x + 1 % this.squaresX, pos.y), Game.Pair(pos.x, squaresBottomY), Game.Pair(squareLeftX, pos.y)];
      edges = [];
      for (_i = 0, _len = squares.length; _i < _len; _i++) {
        square = squares[_i];
        if (grid.squareHasType('snake', square)) continue;
        edges.push([this.vertexCount, this.vertexCount + 1]);
        this.vertexCount += 2;
      }
      return edges;
    };

    return Grid;

  })();

}).call(this);
