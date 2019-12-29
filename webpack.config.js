const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
  entry: './src/game.js',
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  plugins: [
    new CleanWebpackPlugin()
  ],
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
