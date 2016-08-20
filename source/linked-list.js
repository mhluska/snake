class Node {
  constructor(data, list) {
    this.list = list;
    this.data = data;
    this.prev = null;
    this.next = null;
  }

  remove() {
    if (this.prev) {
      this.prev.next = this.next;
    } else {
      this.list._start = this.next;
    }

    if (this.next) {
      this.next.prev = this.prev;
    } else {
      this.list._end = this.prev;
    }

    this.next = null;
    this.prev = null;

    this.list.length -= 1;

    return this.data;
  }
}

class LinkedList {
  constructor(maxSize = Infinity) {
    this.length = 0;
    this.maxSize = maxSize;
    this._end = null;
    this._start = null;
  }

  get start() {
    return this._start ? this._start.data : null;
  }

  get end() {
    return this._end ? this._end.data : null;
  }

  append(data) {
    const node = new Node(data, this);

    this.length += 1;

    if (this.length > this.maxSize) {
      this.removeLeft();
    }

    if (!this._start) {
      this._start = node;
    }

    if (this._end) {
      node.prev = this._end;
      this._end.next = node;
      this._end = node;
    } else {
      this._end = node;
    }

    return data;
  }

  *[Symbol.iterator]() {
    let current = this._start;
    while (current) {
      // We are careful to save a reference to next before yielding because
      // current may get removed.
      let next = current.next;
      yield current;
      current = next;
    }
  }

  remove() {
    if (this._end) {
      return this._end.remove();
    }
  }

  removeLeft() {
    if (this._start) {
      return this._start.remove();
    }
  }

}

module.exports = LinkedList;