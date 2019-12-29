const assert = require('assert');
const Tools = require('./tools');
const Voxel = require('../src/voxel');

class VoxelTests extends Tools {
  static run() {
    super.run('voxel');
  }

  static _directionToTest() {
    let source = new Voxel([6.25, 6.25, 106.25]);
    let target = new Voxel([-6.25, 6.25, 93.75]);

    assert.deepEqual(source.directionTo(target, { sourcePlane: false }).toArray(), [0, 0, -1]);
    assert.deepEqual(source.directionTo(target, { sourcePlane: true }).toArray(),  [-1, 0, 0]);
  }
}

module.exports = VoxelTests;
