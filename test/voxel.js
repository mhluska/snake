var Tools = require('./tools');
var Voxel = require('../source/voxel');

class VoxelTests extends Tools {
  static run() {
    super.run('voxel');
  }

  // TODO(maros): Finish these tests.
  static _directionToTest() {
    this.assert(true);
  }
}

module.exports = VoxelTests;
