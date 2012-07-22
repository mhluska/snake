// Generated by CoffeeScript 1.3.3
(function() {
  'import https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js';

  'import game';

  'import queue';

  'import snake';

  'import grid';

  'import graphics';

  'import graphics2';

  'import pair';

  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.TestGrid = (function(_super) {

    __extends(TestGrid, _super);

    function TestGrid() {
      return TestGrid.__super__.constructor.apply(this, arguments);
    }

    TestGrid.before = function() {
      var linkHtml;
      linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />';
      $('head').append(linkHtml);
      $('body').prepend('<div id="game"></div>');
      return this.game = new SNAKE.Game('#game', {
        useDom: true,
        debugStep: true
      });
    };

    TestGrid.prototype.before = function() {
      this.game = TestGrid.game;
      this.snake = this.game.snake;
      return this.grid = this.game.grid;
    };

    TestGrid.prototype.setupFood = function(coordsArray) {
      var coords, foodPos, _i, _len;
      this.game.restart();
      this.game._gameLoop();
      this.grid.foodItems.dequeue();
      for (_i = 0, _len = coordsArray.length; _i < _len; _i++) {
        coords = coordsArray[_i];
        foodPos = new SNAKE.Pair(coords[0], coords[1]);
        this.grid.dropFood(foodPos);
      }
      return this.game._gameLoop();
    };

    TestGrid.prototype.testRestarts = function() {
      this.game.restart();
      this.game._gameLoop();
      this.grid.foodItems.dequeue();
      this.grid.dropFood(new SNAKE.Pair(5, 5));
      this.grid.dropFood(new SNAKE.Pair(5, 6));
      this.grid.dropFood(new SNAKE.Pair(5, 6));
      this.game._gameLoop();
      this.game.restart();
      this.game.restart();
      this.game._gameLoop();
      this.game._gameLoop();
      this.game.restart();
      this.game._gameLoop();
      this.game._gameLoop();
      this.game._gameLoop();
      return this.game.restart();
    };

    TestGrid.prototype.testClosestFood = function() {
      var closestFood;
      this.setupFood([[this.grid.squaresX - 1, this.grid.squaresY - 1], [0, 0], [4, 6]]);
      closestFood = this.game.snake._findFoodPath().pop();
      this.show("Closest food item: " + (closestFood.toString()));
      return this.assert(closestFood.equals(new SNAKE.Pair(4, 6)));
    };

    TestGrid.prototype.testClosestFoodWrap = function() {
      var closestFood;
      this.setupFood([[this.grid.squaresX - 1, this.grid.squaresY - 1], [0, 0], [this.grid.squaresX - 1, 6]]);
      closestFood = this.game.snake._findFoodPath().pop();
      this.show("Closest food item: " + (closestFood.toString()));
      return this.assert(closestFood.equals(new SNAKE.Pair(this.grid.squaresX - 1, 6)));
    };

    TestGrid.prototype.testModuloBoundaries = function() {
      return console.log('doing test modulo boundaries!');
    };

    return TestGrid;

  })(Test);

}).call(this);
