const assert             = require('assert');
const adjacentUnitVector = require('./adjacent-unit-vector');
const Const              = require('../const');

function fillDimension(vector3, position, scalar, expectedLength = null) {
  if (vector3.x !== 0) position[0] = scalar * vector3.x;
  if (vector3.y !== 0) position[1] = scalar * vector3.y;
  if (vector3.z !== 0) position[2] = scalar * vector3.z;

  assert(expectedLength && position.filter(Boolean).length === expectedLength,
    'Something went wrong during position translation.');
}

module.exports = function(x, y, faceVector, up=null) {
  // We need to provide an arbitrary `up` vector.
  if (!up) {
    up = adjacentUnitVector(faceVector);
  }

  let a = ((x + 1) * Const.TILE_SIZE) - (Const.TILE_SIZE / 2) - (Const.MESH_SIZE / 2);
  let b = ((y + 1) * Const.TILE_SIZE) - (Const.TILE_SIZE / 2) - (Const.MESH_SIZE / 2);
  let c = (Const.TILE_SIZE / 2) + (Const.MESH_SIZE / 2);

  let position = [];
  let cross     = faceVector.clone().cross(up).negate();

  fillDimension(cross,      position, a, 1);
  fillDimension(up,         position, b, 2);
  fillDimension(faceVector, position, c, 3);

  return position;
};
