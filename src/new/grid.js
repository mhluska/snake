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
      this.maxFood = 4;
      this.foodIndex = 0;
      this.foodItems = this.makeFoodItems(this.maxFood);
      this.foodDropRate = 10000;
      this.foodIntervalID = null;
      this.dropFood();
    }

    Grid.prototype.setup = function(graphics) {
      return this.graphics = graphics;
    };

    Grid.prototype.moveSquare = function(start, end, type) {
      this.world[end.x][end.y][type] = this.world[start.x][start.y][type];
      return this.world[start.x][start.y][type] = null;
    };

    Grid.prototype.isEmptySquare = function(square) {
      var squareTypes, type, _i, _len;
      squareTypes = ['food', 'snake'];
      for (_i = 0, _len = squareTypes.length; _i < _len; _i++) {
        type = squareTypes[_i];
        if (square[type]) return false;
      }
      return true;
    };

    Grid.prototype.registerSquare = function(pair, type) {
      return this.world[pair.x][pair.y][type] = true;
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

    Grid.prototype.makeFoodItems = function(maxFood) {
      var foodItems, item, _i;
      foodItems = [];
      for (_i = 0; 0 <= maxFood ? _i < maxFood : _i > maxFood; 0 <= maxFood ? _i++ : _i--) {
        item = this.randPair(this.squaresX - 1, this.squaresY - 1);
        this.registerSquare(item, 'food');
        foodItems.push(item);
      }
      return foodItems;
    };

    Grid.prototype.resetFoodInterval = function() {
      clearInterval(this.foodIntervalID);
      return this.foodIntervalID = setInterval(this.dropFood, this.foodDropRate);
    };

    Grid.prototype.dropFood = function() {
      var food, newFood;
      if (!this.foodItems.length) return;
      food = this.foodItems[this.foodIndex];
      newFood = this.randPair(this.squaresX - 1, this.squaresY - 1);
      this.moveSquare(food, newFood, 'food');
      this.foodItems[this.foodIndex].copy(newFood);
      this.foodIndex = (this.foodIndex + 1) % this.maxFood;
      return this.resetFoodInterval();
    };

    return Grid;

  })();

}).call(this);
