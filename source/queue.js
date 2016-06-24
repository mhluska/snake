// TODO(maros): Implement using linked list if widely used.
class Queue {
  constructor(data, maxSize = Infinity) {
    this._data    = data || [];
    this._maxSize = maxSize;
  }

  get length() {
    return this._data.length;
  }

  toArray() {
    return this._data;
  }

  empty() {
    return this.length === 0;
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
