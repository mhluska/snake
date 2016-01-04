// TODO(maros): Implement using linked list if widely used.
class Queue {
  constructor(data = [], maxSize = Infinity) {
    this._data    = data;
    this._maxSize = maxSize;
  }

  enqueue(item) {
    this._data.unshift(item);
    if (this._data.length > this._maxSize) {
      this._data.pop();
    }
  }

  dequeue() {
    return this._data.pop();
  }
}

module.exports = Queue;
