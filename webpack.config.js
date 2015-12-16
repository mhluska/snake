module.exports = {
  entry: './source/game.js',
  output: {
    path: __dirname + '/build',
    filename: 'snake.js',
    libraryTarget: 'var',
    library: 'SnakeGame'
  },
  resolve: {
    alias: {
      three: 'three.js/build/three.js'
    }
  },
  module: {
    preLoaders: [
      {
          test: /\.js$/,
          exclude: /(node_modules|bower_components)/,
          loader: 'eslint-loader'
      }
    ],
    loaders: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader?presets[]=es2015'
      }
    ]
  },
  eslint: {
    configFile: '.eslintrc'
  }
};
