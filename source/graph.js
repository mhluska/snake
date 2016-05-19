let Queue = require('./queue');

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
  // `start` is the start node.
  // `end` is a target node or a callback to determine if we found the target.
  // `callback` is an action to take after we found the target.
  static bfs(start, end, callback = null) {
    this.visitId += 1;
    return this._bfs(start, end, callback);
  }

  static dijkstra(start, end) {
    this.visitId += 1;
    return this._dijkstra(start, end);
  }

  static _bfs(start, end, callback = null) {
    let nodes = new Queue([start]);
    start.visit();
    start._previous = null;

    while (!nodes.empty()) {
      let currentNode = nodes.dequeue();
      currentNode.visit();

      if (typeof end === 'function' ? end(currentNode) : currentNode === end) {
        return callback ? callback(currentNode) : true;
      }

      for (let adj of currentNode.adjacent) {
        if (adj.visited()) continue;
        nodes.enqueue(adj);
        adj.visit();
        adj._previous = currentNode;
      }
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
