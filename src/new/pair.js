(function() {

  if (window.Game == null) window.Game = {};

  Game.Pair = (function() {

    function Pair(x, y) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
    }

    Pair.prototype.copy = function() {
      return {
        x: this.x,
        y: this.y
      };
    };

    return Pair;

  })();

}).call(this);
