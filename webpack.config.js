module.exports = {
  entry: './source/snake.js',
  output: {
    path: __dirname + '/build',
    filename: 'snake.js'
  },
  resolve: {
    alias: {
      three: 'three.js/build/three.js'
    }
  }
};
