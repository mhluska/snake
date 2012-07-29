// Generated by CoffeeScript 1.3.3
(function() {
  'import require-jquery';

  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.TestCube = (function(_super) {

    __extends(TestCube, _super);

    function TestCube() {
      return TestCube.__super__.constructor.apply(this, arguments);
    }

    TestCube.before = function(start) {
      var _this = this;
      return require(['src/game3'], function(Game) {
        var linkHtml;
        _this.Game = Game;
        linkHtml = '<link rel="stylesheet" type="text/css" href="../snake.css" />';
        $('head').append(linkHtml);
        $('body').prepend('<div id="game"></div>');
        return start();
      });
    };

    TestCube.after = function(start) {
      $('#game').remove();
      $('link').last().remove();
      return start();
    };

    TestCube.prototype.testMakeCube = function() {
      var game;
      game = new TestCube.Game('#game', {
        debugStep: true
      });
      this.show(game.grid.faces, 'Faces:');
      this.assert(game.grid.faces);
      this.show(game.grid.cubeGraph, 'Face graph:');
      return this.assert(game.grid.cubeGraph);
    };

    TestCube.prototype.testGameStep = function() {
      var game;
      game = new TestCube.Game('#game', {
        debugStep: true
      });
      return game._gameLoop();
    };

    return TestCube;

  })(Test);

}).call(this);
