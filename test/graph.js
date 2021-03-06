const assert = require('assert');
const Tools = require('./tools');
const { Graph, Node } = require('../src/graph');

class GraphTests extends Tools {
  static run() {
    super.run('graph');
  }

  static _dijkstraTest() {
    let end   = new Node();
    let start = new Node([new Node([new Node([new Node([end])])])]);

    assert(Graph.dijkstra(start, end).length === 5);
  }

  static _dijkstraCycleTest() {
    let end   = new Node();
    let start = new Node([new Node([new Node([new Node([end])])])]);

    start.firstAdjacent.adjacent.add(start);

    // If the code under tests does not handle cycles, this will enter an
    // infinite loop.
    assert(Graph.dijkstra(start, end).length === 5);
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

    assert(Graph.dijkstra(nodes.a, nodes.i).length === 5);
    assert(Graph.dijkstra(nodes.i, nodes.a).length === 5);
  }
}

module.exports = GraphTests;
