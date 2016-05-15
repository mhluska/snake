var webpack = require("webpack");
var DEPLOY  = process.env.DEPLOY === undefined ? false : true;
var plugins = [];

if (DEPLOY) {
  plugins = [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: false,
      compress: { warnings: false }
    })
  ];
}

module.exports = {
  entry: './source/game.js',
  output: {
    path: __dirname + '/build',
    filename: 'snake.js',
    libraryTarget: 'var',
    library: 'SnakeGame'
  },
  plugins: plugins,
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
