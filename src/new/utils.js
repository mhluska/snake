(function() {

  if (window.Game == null) window.Game = {};

  Game.Utils = (function() {

    function Utils() {}

    Utils.randInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };

    Utils.randPair = function(min1, max1, min2, max2) {
      var randX, randY;
      if (arguments.length === 2) {
        randX = this.randInt(0, min1);
        randY = this.randInt(0, max1);
      } else {
        randX = this.randInt(min1, max1);
        randY = this.randInt(min2, max2);
      }
      return new Game.Pair(randX, randY);
    };

    return Utils;

  })();

}).call(this);
