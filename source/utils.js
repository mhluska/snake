module.exports = class Utils {
  static times(count, callback) {
    for (let index of Array(count)) {
      callback(index);
    }
  }
};
