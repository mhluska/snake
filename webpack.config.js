module.exports = {
  entry: './source/game.js',
  output: {
    path: __dirname + '/build',
    filename: 'snake.js',
    libraryTarget: 'var',
    library: 'SnakeGame'
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
        loader: 'babel',
        query: {
          presets: ['es2015'],
          plugins: ['transform-runtime']
        }
      }
    ]
  },
  eslint: {
    configFile: '.eslintrc',
    formatter: require("eslint-friendly-formatter")
  }
};
