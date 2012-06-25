(function() {

  if (window.Game == null) window.Game = {};

  Game.Pair = (function() {

    function Pair(x, y) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
    }

    Pair.prototype.clone = function() {
      return new Game.Pair(this.x, this.y);
    };

    Pair.prototype.copy = function(pair) {
      if (!pair) return;
      this.x = pair.x;
      return this.y = pair.y;
    };

    return Pair;

  })();

}).call(this);
