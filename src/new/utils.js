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

  Game.Queue = (function() {

    function Queue(items) {
      if (items == null) items = [];
      this._queue = items;
    }

    Queue.prototype.enqueue = function(item) {
      return this._queue.push(item);
    };

    Queue.prototype.dequeue = function() {
      if (!this.size()) return null;
      return this._queue.shift();
    };

    Queue.prototype.size = function() {
      return this._queue.length;
    };

    Queue.prototype.peek = function() {
      return this._queue[0];
    };

    Queue.prototype.isEmpty = function() {
      return this._queue.length === 0;
    };

    Queue.prototype.toString = function() {
      var string;
      string = this._queue.reverse().toString();
      this._queue.reverse();
      return string;
    };

    return Queue;

  })();

}).call(this);
