const Voxel = require('../voxel');

module.exports = function(positionA, positionB) {
  return new Voxel(positionA).adjacentTo(new Voxel(positionB));
};
