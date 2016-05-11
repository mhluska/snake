module.exports = function* (count) {
  for (let i = 0; i < count; i += 1) {
    yield i;
  }
};
