// TODO(maros): Implement using linked list if widely used.
class Queue {
  constructor(data, maxSize = Infinity) {
    this._data    = data || [];
    this._maxSize = maxSize;
  }

  toArray() {
    return this._data;
  }

  size() {
    return this._data.length;
  }

  empty() {
    return this.size() === 0;
  }

  peek() {
    return this._data[0];
  }

  enqueue(item) {
    this._data.push(item);
    if (this._data.length > this._maxSize) {
      this._data.shift();
    }
  }

  dequeue() {
    return this._data.shift();
  }
}

module.exports = Queue;
