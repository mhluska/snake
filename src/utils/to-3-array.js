const assert = require('assert');

module.exports = function(position) {
  if (position.toArray) {
    position = position.toArray();
  }

  assert(position instanceof Array, 'position must be look like an array');
  assert(position.length === 3, 'position must be a 3-array');

  return position;
};
