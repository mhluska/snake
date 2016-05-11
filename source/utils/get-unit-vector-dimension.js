const assert = require('assert');

module.exports = function(unitVector, options={}) {
  assert(unitVector.length() === 1, 'Non unit vector passed to getUnitVectorDimension.');

  const zero = options.zero;

  for (let dimension of 'xyz') {
    if ((zero && unitVector[dimension] === 0) ||
       (!zero && unitVector[dimension] !== 0)) {

      return dimension;
    }
  }
};
