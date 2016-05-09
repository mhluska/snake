var Tools = require('./tools');
var Voxel = require('../source/voxel');

class VoxelTests extends Tools {
  static run() {
    super.run('voxel');
  }

  // TODO(maros): Finish these tests.
  static _directionToTest() {
    let source = new Voxel();
    let target = new Voxel();

    source.directionTo(target);
    this.assert(true);
  }
}

module.exports = VoxelTests;
