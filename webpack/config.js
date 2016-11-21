var path = require("path");
var webpack = require("webpack");

// Ensure a NODE_ENV is also present
if (!process.env.NODE_ENV) {
  throw "No NODE_ENV set";
}

var IS_PRODUCTION = (process.env.NODE_ENV === "production");

// Include a hash of the bundle in the name when we're building these files for
// production so we can use non-expiring caches for them.
//
// Also, if we used hashes in development, we'd be forever filling up our dist
// folder with every hashed version of files we've changed (webpack doesn't
// clean up after itself)
var filenameFormat;
var chunkFilename;
if (IS_PRODUCTION) {
  filenameFormat = "[name]-[chunkhash].js";
  chunkFilename = "[id]-[chunkhash].js";
} else {
  filenameFormat = "[name].js";
  chunkFilename = "[id].js";
}

// Toggle between the devtool if on prod/dev since cheap-module-eval-source-map
// is way faster for development.
var devTool = IS_PRODUCTION ? "source-map" : "cheap-module-eval-source-map";

var plugins = [
  // By default, Webpack uses numerical ID's for it's internal module
  // identification. When you add a module, everything gets shift by 1, which
  // means you end up having a different 'vendor.js' file, if you changed a
  // module in 'app.js', since all the ID's are now +1. NamedModulesPlugin uses
  // the name of the plugin instead of a id, the only problem with this, is
  // that it bloats file size, because instead of "1" being the ID, it's now
  // "../../node_modules/react/index.js" or something. In saying that though,
  // after gzipping, it's not a real problem.
  new webpack.NamedModulesPlugin(),

  // When you set NODE_ENV=production, that only sets it for the Webpack NodeJS
  // environment. We need to also send the variable to the JS compilation
  // inside Babel, so packages like React know now to include development
  // helpers. Doing this greatly reduces file size, and makes React faster
  // since it doesn't have to do a ton of type checking (which it only does to
  // help developers with error messages)
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify(process.env.NODE_ENV)
    }
  })
];

// If we're building for production, minify the JS
if (IS_PRODUCTION) {
  // Need this plugin to ensure consistent module ordering so we can have
  // determenistic filename hashes
  plugins.push(new webpack.optimize.OccurenceOrderPlugin(true));

  // Don't pack react-type-snob in production
  plugins.push(new webpack.IgnorePlugin(/^react-type-snob$/));

  // Your basic, run-of-the-mill, JS uglifier
  plugins.push(new webpack.optimize.UglifyJsPlugin({
    output: {
      comments: false
    },
    compress: {
      warnings: false,
      screw_ie8: true
    }
  }));
}

module.exports = {
  context: __dirname,

  devtool: devTool,

  entry: {
    app: path.join(__dirname, '../app/app.js')
  },

  output: {
    filename: filenameFormat,
    chunkFilename: chunkFilename,
    path: path.join(__dirname, '..', 'dist'),
    publicPath: path.join(__dirname, '..', 'assets')
  },

  module: {
    loaders: [
      {
        test: /\.js$/i,
        loader: 'babel',
        exclude: /node_modules/
      },
      {
        test: /\.mdx$/i,
        loader: 'babel-loader!markdown-component-loader?passElementProps=true'
      }
    ]
  },

  plugins: plugins
};
