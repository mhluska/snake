(function() {
  'import graph';
  var TestGraph, test,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  TestGraph = (function(_super) {

    __extends(TestGraph, _super);

    function TestGraph() {
      this.run = __bind(this.run, this);
      TestGraph.__super__.constructor.apply(this, arguments);
    }

    TestGraph.prototype.run = function() {
      var dijkstras, distance, edgeWeights, graph;
      edgeWeights = [['a', 'b', 2], ['a', 'c', 8], ['a', 'd', 20], ['d', 'c', 9], ['c', 'f', 1], ['d', 'f', 1], ['e', 'e', 0]];
      this.show(edgeWeights, "Edge weights:");
      graph = new Game.Graph(edgeWeights);
      this.show(graph._neighbours, "Internal neighbours object:");
      this.assert(graph._neighbours['a'].length === 3, "Vertex a has 3 neighbours");
      this.show(graph.vertices(), 'Vertices:');
      this.show(graph._distanceBetween, 'Internal distanceBetween object:');
      distance = graph.distanceBetween(graph.vertices()[0], graph.vertices()[1]);
      this.show(distance, 'Distance between vertices a and b:');
      dijkstras = graph.dijkstras('a', 'd');
      this.show(dijkstras, "Result of Dijkstra's algorithm:");
      return this.assert(this.equals(dijkstras, ['c', 'f', 'd']), "Shortest path from 'a' to 'd'");
    };

    return TestGraph;

  })(Test);

  test = new TestGraph;

  test.run();

}).call(this);
