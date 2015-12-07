module.exports = {
  entry: './source/game.js',
  output: {
    path: __dirname + '/build',
    filename: 'snake.js',
    libraryTarget: 'var',
    library: 'Snake'
  },
  resolve: {
    alias: {
      three: 'three.js/build/three.js'
    }
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel'
      }
    ]
  }
};
