(function() {

  if (window.Game == null) window.Game = {};

  Game.Graphics = (function() {

    function Graphics(grid, graphicsType) {
      this.grid = grid;
      this.graphicsType = graphicsType != null ? graphicsType : 'dom';
      this.grid.setup(this);
      if (this.graphicsType === 'dom') this.buildDOM();
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
      var column, pos, square, type, x, y, _i, _len, _len2, _len3, _ref, _ref2;
      _ref = this.grid.world;
      for (x = 0, _len = _ref.length; x < _len; x++) {
        column = _ref[x];
        for (y = 0, _len2 = column.length; y < _len2; y++) {
          square = column[y];
          pos = new Game.Pair(x, y);
          _ref2 = this.grid.squareTypes;
          for (_i = 0, _len3 = _ref2.length; _i < _len3; _i++) {
            type = _ref2[_i];
            if (this.grid.isRegistered(square[type])) {
              square[type] = this.appendDOMNode(pos, type);
              return;
            }
            if (square[type]) this.setNodePosition(square[type], pos);
          }
        }
      }
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
      this.dom.squares.push(node);
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
      this.dom.squares = [];
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
