// Common client-side webpack configuration used by webpack.hot.config and webpack.rails.config.

const webpack = require('webpack');
const path = require('path');
const glob = require("glob");
const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';
const autoprefixer = require('autoprefixer');

module.exports = {
  context: __dirname,
  entry: {
    vendor: [
      'babel-polyfill',
      'jquery',
    ].concat(glob.sync("./app/lib/raw/**/*.js")),

    app: [
      './app/bundles/BrandApp/startup/clientRegistration',
    ],
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.less', '.png', '.jpg', '.gif', '.css'],
    root: [
      path.resolve('./app/lib'),
      path.resolve('./assets/stylesheets'),
      path.resolve('./assets/images'),
    ],
    alias: {
      lib: path.join(process.cwd(), 'app', 'lib'),
      react: path.resolve('./node_modules/react'),
      'react-dom': path.resolve('./node_modules/react-dom'),
    },
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    }),
  ],
  module: {
    loaders: [
      // 加载普通静态资源
      { test: /\.(woff2?|svg)$/, loader: 'url?name=brand-[name]-[hash].[ext]&limit=10000' },
      { test: /\.(ttf|eot)$/, loader: 'file?name=brand-[name]-[hash].[ext]' },
      { test: /\.(jpe?g|png|gif|svg|ico)$/, loader: 'url?name=brand-[name]-[hash].[ext]&limit=10000' },

      // 扩展全局namespace
      { test: require.resolve('jquery'), loader: 'expose?jQuery' },
      { test: require.resolve('jquery'), loader: 'expose?$' },

      {
        test: require.resolve('jquery-ujs'),
        loader: 'imports?jQuery=jquery',
      },
    ],
  },
  postcss: [autoprefixer],
};
