const THREE  = require('three');
const assert = require('assert');

module.exports = function(unitVector) {
  assert(unitVector.length() === 1, 'Non unit vector passed to adjacentUnitVector.');

  let units = unitVector.toArray();
  units.unshift(units.pop());
  return new THREE.Vector3(...units);
};
