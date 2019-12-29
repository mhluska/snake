const webpack = require('webpack');
const plugins = [];

if (process.env.DEPLOY) {
  plugins = [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: false,
      compress: { warnings: false }
    })
  ];
}

module.exports = {
  entry: './src/game.js',
  output: {
    path: __dirname + '/dist',
    filename: 'snake.js',
    libraryTarget: 'var',
    library: 'SnakeGame'
  },
  plugins: plugins,
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env']
            },
          },
          'eslint-loader'
        ],
      },
    ],
  },
};
