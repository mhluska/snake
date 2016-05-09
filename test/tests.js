var GraphTests = require('./graph');
var VoxelTests = require('./voxel');

class Tests {
  static run() {
    GraphTests.run();
    VoxelTests.run();
  }
}

module.exports = Tests;
