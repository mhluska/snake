const GraphTests      = require('./graph');
const VoxelTests      = require('./voxel');
const LinkedListTests = require('./linked-list');

class Tests {
  static run() {
    GraphTests.run();
    VoxelTests.run();
    LinkedListTests.run();
  }
}

module.exports = Tests;
