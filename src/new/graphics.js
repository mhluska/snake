(function() {

  if (window.Game == null) window.Game = {};

  Game.Graphics = (function() {

    function Graphics(grid, graphicsType) {
      this.grid = grid;
      this.graphicsType = graphicsType != null ? graphicsType : 'dom';
      this.grid.setup(this);
      if (this.graphicsType === 'dom') this.buildDOM();
      this.nodeRemoveQueue = [];
    }

    Graphics.prototype.setNodePosition = function(node, pos) {
      var offset;
      if (!node) return;
      offset = this.dom.grid.offset();
      node.css({
        top: offset.top + pos.y * this.grid.squareHeight,
        left: offset.left + pos.x * this.grid.squareWidth
      });
      return node.show();
    };

    Graphics.prototype.update = function() {
      var column, pos, square, type, x, y, _len, _ref, _results;
      this.deleteZombieSquares();
      _ref = this.grid.world;
      _results = [];
      for (x = 0, _len = _ref.length; x < _len; x++) {
        column = _ref[x];
        _results.push((function() {
          var _len2, _results2;
          _results2 = [];
          for (y = 0, _len2 = column.length; y < _len2; y++) {
            square = column[y];
            pos = new Game.Pair(x, y);
            _results2.push((function() {
              var _i, _len3, _ref2, _results3;
              _ref2 = this.grid.squareTypes;
              _results3 = [];
              for (_i = 0, _len3 = _ref2.length; _i < _len3; _i++) {
                type = _ref2[_i];
                if (square[type] === true) {
                  square[type] = this.appendDOMNode(pos, type);
                }
                if (square[type]) {
                  _results3.push(this.setNodePosition(square[type], pos));
                } else {
                  _results3.push(void 0);
                }
              }
              return _results3;
            }).call(this));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    Graphics.prototype.deleteZombieSquares = function() {
      var _results;
      _results = [];
      while (this.nodeRemoveQueue.length) {
        _results.push(this.deleteSquare(this.nodeRemoveQueue.pop()));
      }
      return _results;
    };

    Graphics.prototype.deleteSquare = function(square) {
      square.remove();
      return square = null;
    };

    Graphics.prototype.buildDOMNode = function(pos, type) {
      var node;
      node = $("<div class='" + type + "'></div>");
      node.css({
        width: this.grid.squareWidth,
        height: this.grid.squareHeight
      });
      this.setNodePosition(node, pos);
      return node;
    };

    Graphics.prototype.appendDOMNode = function(pos, type) {
      var node;
      node = this.buildDOMNode(pos, type);
      return node.appendTo(this.dom.grid);
    };

    Graphics.prototype.buildDOM = function() {
      var column, pos, square, type, x, y, _len, _ref, _results;
      this.dom = {};
      this.dom.grid = $('<div id="grid"></div>');
      this.dom.grid.css({
        width: this.grid.squareWidth * this.grid.squaresX,
        height: this.grid.squareHeight * this.grid.squaresY
      });
      $('body').append(this.dom.grid);
      _ref = this.grid.world;
      _results = [];
      for (x = 0, _len = _ref.length; x < _len; x++) {
        column = _ref[x];
        _results.push((function() {
          var _len2, _results2;
          _results2 = [];
          for (y = 0, _len2 = column.length; y < _len2; y++) {
            square = column[y];
            if (this.grid.isEmptySquare(square)) continue;
            if (square.snake) type = 'snake';
            if (square.food) type = 'food';
            pos = new Game.Pair(x, y);
            _results2.push(square[type] = this.appendDOMNode(pos, type));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    return Graphics;

  })();

}).call(this);
