(function() {

  if (window.Game == null) window.Game = {};

  Game.Snake = (function() {

    function Snake(length, position) {
      var piece, x, y;
      this.length = length != null ? length : 5;
      this.position = position;
      if (this.position == null) this.position = new Game.Pair(0, 4);
      x = this.position.x;
      y = this.position.y;
      this.chain = (function() {
        var _ref, _results;
        _results = [];
        for (piece = 0, _ref = this.length - 1; 0 <= _ref ? piece <= _ref : piece >= _ref; 0 <= _ref ? piece++ : piece--) {
          _results.push(new Game.Pair(x, y - piece));
        }
        return _results;
      }).call(this);
    }

    Snake.prototype.setup = function(grid) {
      var pair, _i, _len, _ref, _results;
      this.grid = grid;
      _ref = this.chain;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        _results.push(this.grid.registerSquare(pair, 'snake'));
      }
      return _results;
    };

    Snake.prototype.move = function() {
      var head, index, moveTo, piece, tail, temp, _len, _ref, _ref2, _ref3;
      head = this.chain[0];
      tail = this.chain[this.chain.length - 1].copy();
      if (this.position.y >= this.grid.squaresY - 1) return;
      this.position.y += 1;
      moveTo = this.position.copy();
      temp = head.copy();
      _ref = this.chain;
      for (index = 0, _len = _ref.length; index < _len; index++) {
        piece = _ref[index];
        this.grid.moveSquare(piece, moveTo, 'snake');
        piece.x = moveTo.x;
        piece.y = moveTo.y;
        moveTo.x = temp.x;
        moveTo.y = temp.y;
        temp.x = (_ref2 = this.chain[index + 1]) != null ? _ref2.x : void 0;
        temp.y = (_ref3 = this.chain[index + 1]) != null ? _ref3.y : void 0;
      }
      return this.grid.world[tail.x][tail.y].snake = null;
    };

    return Snake;

  })();

}).call(this);
