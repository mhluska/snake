// Generated by CoffeeScript 1.3.3
(function() {
  var __slice = [].slice;

  SNAKE.Snake = (function() {

    function Snake(game, length, direction, head) {
      var piece, x, y, _ref;
      this.game = game;
      this.length = length != null ? length : 5;
      this.direction = direction != null ? direction : 'down';
      this.head = head;
      this.grid = null;
      this.lastTailPos = null;
      this.moves = new SNAKE.Queue;
      this.stepsPerGrowth = 3;
      this.growUntil = 0;
      this.autoPlay = true;
      if ((_ref = this.head) == null) {
        this.head = new SNAKE.Pair(0, 4);
      }
      x = this.head.x;
      y = this.head.y;
      this.chain = (function() {
        var _i, _ref1, _results;
        _results = [];
        for (piece = _i = 0, _ref1 = this.length - 1; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; piece = 0 <= _ref1 ? ++_i : --_i) {
          _results.push(new SNAKE.Pair(x, y - piece));
        }
        return _results;
      }).call(this);
      this._setupControls();
    }

    Snake.prototype._nextPosition = function(position) {
      var nextPos;
      if (position == null) {
        position = this.head;
      }
      nextPos = position.clone();
      switch (this.direction) {
        case 'up':
          nextPos.y -= 1;
          break;
        case 'right':
          nextPos.x += 1;
          break;
        case 'down':
          nextPos.y += 1;
          break;
        case 'left':
          nextPos.x -= 1;
      }
      nextPos = this.grid.moduloBoundaries(nextPos);
      if (!this.autoPlay) {
        return nextPos;
      }
      return this._avoidDeathOnPosition(position, nextPos);
    };

    Snake.prototype._avoidDeathOnPosition = function(position, nextPosition) {
      var _this = this;
      if (!this.grid.squareHasType('snake', nextPosition)) {
        return nextPosition;
      }
      this.grid.eachAdjacentPosition(position, function(adjPos, direction) {
        if (!(_this._isOpposite(direction) || _this.grid.squareHasType('snake', adjPos))) {
          nextPosition = adjPos;
          return false;
        }
      });
      return nextPosition;
    };

    Snake.prototype._nextDirection = function(position) {
      var nextDirection;
      if (!position) {
        return;
      }
      nextDirection = this.direction;
      this.grid.eachAdjacentPosition(this.head, function(adjPosition, direction) {
        if (position.equals(adjPosition)) {
          nextDirection = direction;
          return false;
        }
      });
      return nextDirection;
    };

    Snake.prototype._setupControls = function() {
      var _this = this;
      $(window).one('keydown', function() {
        var _results;
        if (_this.game.debugStep) {
          return;
        }
        _this.autoPlay = false;
        _results = [];
        while (!_this.moves.isEmpty()) {
          _results.push(_this.moves.dequeue());
        }
        return _results;
      });
      return $(window).keydown(function(event) {
        var newDirection;
        newDirection = _this.direction;
        switch (event.keyCode) {
          case 37:
            newDirection = 'left';
            break;
          case 38:
            newDirection = 'up';
            break;
          case 39:
            newDirection = 'right';
            break;
          case 40:
            newDirection = 'down';
            break;
          default:
            return;
        }
        if (!_this._isOpposite(newDirection)) {
          _this.direction = newDirection;
          return _this.moves.enqueue(_this._nextPosition(_this.moves.back()));
        }
      });
    };

    Snake.prototype._isOpposite = function(newDirection) {
      if (newDirection === 'left' && this.direction === 'right') {
        return true;
      }
      if (newDirection === 'right' && this.direction === 'left') {
        return true;
      }
      if (newDirection === 'up' && this.direction === 'down') {
        return true;
      }
      if (newDirection === 'down' && this.direction === 'up') {
        return true;
      }
      return false;
    };

    Snake.prototype._grow = function() {
      if (!this.lastTailPos) {
        return;
      }
      this.chain.push(this.lastTailPos);
      this.grid.registerSquareAt(this.lastTailPos, 'snake');
      return this.grid.unregisterFoodAt(this.chain[0]);
    };

    Snake.prototype._findFoodPath = function() {
      var foodPositions, graph, pairs;
      foodPositions = this.grid.visibleFood();
      if (!foodPositions.length) {
        return [];
      }
      graph = new SNAKE.Graph(this.grid.toGraph());
      pairs = graph.dijkstras.apply(graph, [this.head.toString()].concat(__slice.call(foodPositions)));
      pairs = pairs.map(function(pair) {
        return new SNAKE.Pair(pair);
      });
      return pairs;
    };

    Snake.prototype._updateMoves = function() {
      var pair, _i, _len, _ref, _results;
      if (this.autoPlay && this.moves.isEmpty()) {
        _ref = this._findFoodPath();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          pair = _ref[_i];
          _results.push(this.moves.enqueue(pair));
        }
        return _results;
      }
    };

    Snake.prototype._getNextHead = function() {
      if (this.moves.isEmpty()) {
        return this._nextPosition();
      } else {
        return this.moves.dequeue();
      }
    };

    Snake.prototype._eating = function() {
      return this.game.stepCount < this.growUntil;
    };

    Snake.prototype.setup = function(grid) {
      var pair, _i, _len, _ref, _results;
      this.grid = grid;
      _ref = this.chain;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        _results.push(this.grid.registerSquareAt(pair, 'snake'));
      }
      return _results;
    };

    Snake.prototype.move = function() {
      var nextHead;
      if (!this.direction) {
        return;
      }
      if (this.grid.squareHasType('food', this.head)) {
        this.growUntil = this.game.stepCount + this.stepsPerGrowth;
      }
      if (this._eating()) {
        this._grow();
      }
      this._updateMoves();
      nextHead = this._getNextHead();
      this.direction = this._nextDirection(nextHead);
      this.head = nextHead;
      if (this.grid.squareHasType('snake', this.head)) {
        this.game.restart();
      }
      this.lastTailPos = this.chain[this.chain.length - 1].clone();
      this.grid.moveSquare(this.lastTailPos, this.head, 'snake');
      this.chain.pop();
      return this.chain.unshift(this.head.clone());
    };

    return Snake;

  })();

}).call(this);
