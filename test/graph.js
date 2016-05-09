var Tools = require('./tools');
var { Graph, Node } = require('../source/graph');

class GraphTests extends Tools {
  static run() {
    super.run('graph');
  }

  static _dijkstraTest() {
    let end   = new Node();
    let start = new Node([new Node([new Node([new Node([end])])])]);

    this.assert(Graph.dijkstra(start, end).length === 5);
  }

  static _dijkstraCycleTest() {
    let end   = new Node();
    let start = new Node([new Node([new Node([new Node([end])])])]);

    start.firstAdjacent.adjacent.add(start);

    // If the code under tests does not handle cycles, this will enter an
    // infinite loop.
    this.assert(Graph.dijkstra(start, end).length === 5);
  }

  // . . . . . . .
  // . a . b . c .
  // . . . . . . .
  // . d . e . f .
  // . . . . . . .
  // . g . h . i .
  // . . . . . . .
  static _dijkstraTileTest() {
    let nodes = {};
    for (let name of 'abcdefghi'.split('')) {
      nodes[name] = new Node();
    }

    let edges = {
      a: ['b', 'd'],
      b: ['a', 'e', 'c'],
      c: ['b', 'f'],
      d: ['e', 'g', 'a'],
      e: ['b', 'f', 'h', 'd'],
      f: ['c', 'e', 'i'],
      g: ['d', 'h'],
      h: ['e', 'g', 'i'],
      i: ['f', 'h']
    };

    for (let nodeName in edges) {
      for (let adjacentNodeName of edges[nodeName]) {
        nodes[nodeName].adjacent.add(nodes[adjacentNodeName]);
      }
    }

    this.assert(Graph.dijkstra(nodes.a, nodes.i).length === 5);
    this.assert(Graph.dijkstra(nodes.i, nodes.a).length === 5);
  }
}

module.exports = GraphTests;
