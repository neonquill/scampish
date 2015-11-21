var webpack = require('webpack');

module.exports = {
  entry: 'main.js',
  output: {
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.ProvidePlugin({
      riot: 'riot'
    })
  ],
  module: {
    loaders: [
      { test: /\.json$/, loader: "json" }
    ],
    preLoaders: [
      { test: /\.tag$/, exclude: /node_modules/, loader: 'riotjs-loader',
        query: { type: 'none' } }
    ]
  },
  resolve: {
    modulesDirectories: ['scripts', 'tags', 'vendor', 'node_modules']
  }
};
