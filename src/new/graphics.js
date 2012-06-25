(function() {

  if (window.Game == null) window.Game = {};

  Game.Graphics = (function() {

    function Graphics(grid, graphicsType) {
      this.grid = grid;
      this.graphicsType = graphicsType != null ? graphicsType : 'dom';
      if (this.graphicsType === 'dom') this.buildDOMElems();
    }

    Graphics.prototype.update = function() {};

    Graphics.prototype.buildDOMElems = function() {
      var column, elem, square, squareX, squareY, type, _len, _len2, _ref;
      this.dom = {};
      this.dom.grid = $('<div id="grid"></div>');
      this.dom.grid.css({
        width: this.grid.squareWidth * this.grid.squaresX,
        height: this.grid.squareHeight * this.grid.squaresY
      });
      this.dom.squares = [];
      _ref = this.grid.world;
      for (squareX = 0, _len = _ref.length; squareX < _len; squareX++) {
        column = _ref[squareX];
        for (squareY = 0, _len2 = column.length; squareY < _len2; squareY++) {
          square = column[squareY];
          if ($.isEmptyObject(square)) continue;
          if (square.snake) type = 'snake';
          if (square.food) type = 'food';
          elem = {
            x: squareX,
            y: squareY,
            type: type
          };
          elem.node = $("<div class='" + type + "'></div>");
          elem.node.css({
            x: elem.x,
            y: elem.y
          });
          this.dom.squares.push(elem);
          this.dom.grid.append(elem.node);
        }
      }
      return $('body').append(this.dom.grid);
    };

    return Graphics;

  })();

}).call(this);
