var Queue = require('./queue');

class Node {
  constructor(adjacent = []) {
    this.adjacent = new Set(adjacent);

    // Used internally for pathfinding.
    this._previous = null;
    this._visitId  = 0;
  }

  get firstAdjacent() {
    return this.adjacent.values().next().value;
  }

  visited() {
    return this._visitId === Graph.visitId;
  }

  visit() {
    this._visitId = Graph.visitId;
  }
}

class Graph {
  static bfs(start, end, callback = null) {
    this.visitId += 1;
    return this._bfs(start, end, callback);
  }

  static dijkstra(start, end) {
    this.visitId += 1;
    return this._dijkstra(start, end);
  }

  static _bfs(start, end, callback = null) {
    let nodes    = new Queue([start]);
    let lastNode = null;

    while (!nodes.empty()) {
      let currentNode = nodes.dequeue();

      if (currentNode.visited()) continue;

      currentNode.visit();

      if (lastNode) {
        currentNode._previous = lastNode;
      }

      if (currentNode === end) {
        return callback ? callback(end) : true;
      }

      currentNode.adjacent.forEach(adj => { nodes.enqueue(adj); });
      lastNode = currentNode;
    }

    return false;
  }

  static _dijkstra(start, end) {
    return this._bfs(start, end, this._retracePath);
  }

  static _retracePath(node) {
    let path = [node];

    while (node._previous) {
      path.push(node._previous);
      node = node._previous;
    }

    return path.reverse();
  }
}

Graph.visitId = 0;

module.exports = {
  Graph: Graph,
  Node:  Node
};
