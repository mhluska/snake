(function() {

  if (window.Game == null) window.Game = {};

  Game.Graphics = (function() {

    function Graphics(grid, graphicsType) {
      this.grid = grid;
      this.graphicsType = graphicsType != null ? graphicsType : 'dom';
      this.grid.setup(this);
      if (this.graphicsType === 'dom') this.buildDOM();
    }

    Graphics.prototype.setNodePosition = function(node, x, y) {
      var offset;
      if (!node) return;
      offset = this.dom.grid.offset();
      node.css({
        top: offset.top + y * this.grid.squareHeight,
        left: offset.left + x * this.grid.squareWidth
      });
      return node.show();
    };

    Graphics.prototype.update = function() {
      var column, square, x, y, _len, _ref, _results;
      _ref = this.grid.world;
      _results = [];
      for (x = 0, _len = _ref.length; x < _len; x++) {
        column = _ref[x];
        _results.push((function() {
          var _len2, _results2;
          _results2 = [];
          for (y = 0, _len2 = column.length; y < _len2; y++) {
            square = column[y];
            if (square.snake) {
              _results2.push(this.setNodePosition(square.snake.node, x, y));
            } else {
              _results2.push(void 0);
            }
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    Graphics.prototype.buildDOMElem = function(x, y, type) {
      var elem;
      elem = {
        x: x,
        y: y,
        node: $("<div class='" + type + "'></div>")
      };
      this.setNodePosition(elem.node, elem.x, elem.y);
      elem.node.css({
        width: this.grid.squareWidth,
        height: this.grid.squareHeight
      });
      return elem;
    };

    Graphics.prototype.buildDOM = function() {
      var column, elem, square, type, x, y, _len, _ref, _results;
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
            elem = this.buildDOMElem(x, y, type);
            square[type] = elem;
            this.dom.squares.push(elem);
            _results2.push(this.dom.grid.append(elem.node));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    return Graphics;

  })();

}).call(this);
