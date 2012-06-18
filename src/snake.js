(function() {
  var Snake;

  if (window.Game == null) window.Game = {};

  Game.Snake = Snake = (function() {

    function Snake(direction) {
      var piece;
      this.direction = direction != null ? direction : 'down';
      this.x = 4;
      this.y = 4;
      this.length = 5;
      this.boundaryX = null;
      this.boundaryY = null;
      this.lastTailPosition = null;
      this.queuedDirection = this.direction;
      this.chain = (function() {
        var _ref, _results;
        _results = [];
        for (piece = 0, _ref = this.length - 1; 0 <= _ref ? piece <= _ref : piece >= _ref; 0 <= _ref ? piece++ : piece--) {
          _results.push({
            x: this.x,
            y: this.y - piece
          });
        }
        return _results;
      }).call(this);
      this.setupControls();
    }

    Snake.prototype.setupControls = function() {
      var _this = this;
      return $(window).keydown(function(event) {
        var newDirection;
        newDirection = _this.queuedDirection;
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
        }
        if (!_this.isOpposite(newDirection)) {
          return _this.queuedDirection = newDirection;
        }
      });
    };

    Snake.prototype.isOpposite = function(newDirection) {
      if (newDirection === 'left' && this.direction === 'right') return true;
      if (newDirection === 'right' && this.direction === 'left') return true;
      if (newDirection === 'up' && this.direction === 'down') return true;
      if (newDirection === 'down' && this.direction === 'up') return true;
      return false;
    };

    Snake.prototype.cage = function(squaresX, squaresY) {
      this.boundaryX = squaresX;
      return this.boundaryY = squaresY;
    };

    Snake.prototype.move = function() {
      var index, moveTo, piece, tail, temp, _len, _ref, _ref2, _ref3, _results;
      tail = this.chain[this.chain.length - 1];
      this.lastTailPosition = {
        x: tail.x,
        y: tail.y
      };
      this.direction = this.queuedDirection;
      switch (this.direction) {
        case 'up':
          if (this.y <= 0) return;
          this.y -= 1;
          break;
        case 'right':
          if (this.x >= this.boundaryX - 1) return;
          this.x += 1;
          break;
        case 'down':
          if (this.y >= this.boundaryY - 1) return;
          this.y += 1;
          break;
        case 'left':
          if (this.x <= 0) return;
          this.x -= 1;
      }
      moveTo = {
        x: this.x,
        y: this.y
      };
      temp = {
        x: this.chain[0].x,
        y: this.chain[0].y
      };
      _ref = this.chain;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        piece = _ref[index];
        piece.x = moveTo.x;
        piece.y = moveTo.y;
        moveTo.x = temp.x;
        moveTo.y = temp.y;
        temp.x = (_ref2 = this.chain[index + 1]) != null ? _ref2.x : void 0;
        _results.push(temp.y = (_ref3 = this.chain[index + 1]) != null ? _ref3.y : void 0);
      }
      return _results;
    };

    Snake.prototype.grow = function() {
      this.chain.push(this.lastTailPosition);
      return this.lastTailPosition;
    };

    return Snake;

  })();

}).call(this);
