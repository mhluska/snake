const LinkedList = require('./linked-list');

class Queue {
  constructor(data, maxSize = Infinity) {
    this._list    = new LinkedList(maxSize);
    this._maxSize = maxSize;

    if (data) {
      for (let item of data) {
        this._list.append(item);
      }
    }
  }

  get length() {
    return this._list.length;
  }

  empty() {
    return this.length === 0;
  }

  peek() {
    return this._list.start;
  }

  enqueue(item) {
    this._list.append(item);
  }

  dequeue() {
    return this._list.removeLeft();
  }
}

module.exports = Queue;
