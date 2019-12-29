const random = require('./random');

module.exports = function(array) {
  for (let index = 0; index < array.length - 1; index += 1) {
    let item        = array[index];
    let randomIndex = random(index + 1, array.length);
    let temp        = array[randomIndex];

    array[randomIndex] = item;
    array[index] = temp;
  }

  return array;
};
