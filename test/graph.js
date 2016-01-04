var Tools = require('./tools');
var { Graph, Node } = require('../source/graph');

class GraphTests extends Tools {
  static run() {
    console.log('Running graph tests...');

    let [passed, total, error] = super.run();

    if (passed === total) {
      console.log('All tests passed');
    } else {
      console.log(`${passed}/${total} tests passed.`);
      throw error;
    }
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
}

module.exports = GraphTests;
