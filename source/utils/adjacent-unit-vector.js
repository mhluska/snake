const THREE = require('three');
const assert = require('assert');
const to3Array = require('./to-3-array');

module.exports = function(unitVector) {
  assert(unitVector.length() === 1, 'Non unit vector passed to adjacentUnitVector.');

  let units = to3Array(unitVector);
  units.unshift(units.pop());
  return new THREE.Vector3(...units);
};
