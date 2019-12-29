const assert     = require('assert');
const Tools      = require('./tools');
const times      = require('../src/utils/times');
const LinkedList = require('../src/linked-list');

class LinkedListTests extends Tools {
  static run() {
    super.run('linked-list');
  }

  static _initialSizeTest() {
    const list = new LinkedList();
    assert(list.length === 0);
  }

  static _appendTest() {
    const list = this._initList();
    assert(list.length === 4);
  }

  static _removeTest() {
    const list = this._initList();

    for (let node of list) {
      if (node.data === 5) {
        node.remove();
      }
    }

    assert(list.length === 3);
  }

  static _removeAllTest() {
    const list = this._initList();

    for (let i of times(10)) {
      list.remove(i);
    }

    assert(!list.start);
    assert(!list.end);
    assert(list.length === 0);
  }

  static _removeAllLeftTest() {
    const list = this._initList();

    for (let i of times(10)) {
      list.removeLeft(i);
    }

    assert(!list.start);
    assert(!list.end);
    assert(list.length === 0);
  }

  static _initList() {
    const list = new LinkedList();
    list.append(1);
    list.append(3);
    list.append(5);
    list.append(7);

    return list;
  }
}

module.exports = LinkedListTests;
