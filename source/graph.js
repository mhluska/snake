var Queue = require('./queue');

class Node {
  constructor(adjacent = []) {
    this.adjacent = new Set(adjacent);

    // Used internally for pathfinding.
    this._previous = null;
  }
}

class Graph {
  static bfs(start, end, callback = null) {
    let nodes = new Queue([start]);

    while (!nodes.empty()) {
      if (nodes.peek() === end) {
        if (callback) {
          return callback(end);
        } else {
          return true;
        }
      }

      let currentNode = nodes.dequeue();
      currentNode.adjacent.forEach(adj => {
        nodes.enqueue(adj);
        adj._previous = currentNode;
      });
    }

    return false;
  }

  static dijkstra(start, end) {
    return this.bfs(start, end, this._retracePath);
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

module.exports = {
  Graph: Graph,
  Node:  Node
};
