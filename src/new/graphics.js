(function() {

  if (window.Game == null) window.Game = {};

  Game.Graphics = (function() {

    function Graphics(grid) {
      this.grid = grid;
    }

    Graphics.prototype.update = function() {};

    return Graphics;

  })();

}).call(this);
