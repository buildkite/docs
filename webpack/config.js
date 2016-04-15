var path = require("path");
var webpack = require("webpack");
var HtmlWebpackPlugin = require('html-webpack-plugin');

// Validate DOCS_HOST to make sure it's present an in the right format
if(!process.env.DOCS_HOST) throw "No DOCS_HOST set";
if(process.env.DOCS_HOST.slice(-1) != "/") throw "DOCS_HOST must end with a /";

module.exports = {
  context: __dirname,

  entry: '../app/app.js',

  output: {
    filename: "bundle.js",
    path: path.join(__dirname, '..', 'dist'),
    publicPath: process.env.DOCS_HOST
  },

  module: {
    loaders: [
      {
        test: /\.css$/i,
        loader: "style-loader!css-loader!postcss-loader"
      },
      {
        test: /\.js$/i,
        loader: 'babel',
        exclude: /node_modules/
      },
      {
        test: /\.(png|svg|jpg|gif)$/i,
        loaders: [
          'url-loader?limit=8192',
          'image-webpack?optimizationLevel=7&interlaced=false'
        ]
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'layout.ejs'
    })
  ],

  postcss: function (webpack) {
    return [
      require("postcss-import")({ addDependencyTo: webpack }),
      require("postcss-cssnext")()
    ]
  },

  devServer: {
    historyApiFallback: true
  }
};
