const assert = require('assert');

module.exports = function(...args) {
  assert(args.every(Boolean));
};
