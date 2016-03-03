// Common client-side webpack configuration used by webpack.hot.config and webpack.rails.config.

const webpack = require('webpack');
const path = require('path');

const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

module.exports = {

  // the project dir
  context: __dirname,
  entry: {

    // See use of 'vendor' in the CommonsChunkPlugin inclusion below.
    vendor: [
      'babel-polyfill',
      'jquery',
    ],

    // This will contain the app entry points defined by webpack.hot.config and
    // webpack.rails.config
    app: [
      './app/bundles/BrandApp/startup/clientRegistration',
    ],
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.less', '.png', '.jpg', '.gif', '.css'],
    root: [
      path.resolve('./assets/stylesheets'),
      path.resolve('./assets/images')
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

    // https://webpack.github.io/docs/list-of-plugins.html#2-explicit-vendor-chunk
    new webpack.optimize.CommonsChunkPlugin({

      // This name 'vendor' ties into the entry definition
      name: 'vendor',

      // We don't want the default vendor.js name
      filename: 'vendor-bundle.js',

      // Passing Infinity just creates the commons chunk, but moves no modules into it.
      // In other words, we only put what's in the vendor entry definition in vendor-bundle.js
      minChunks: Infinity,
    }),
  ],
  module: {
    loaders: [
      // 加载bootstrap资源
      {test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/font-woff'},
      {test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/octet-stream'},
      {test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, loader: 'file'},
      {test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=image/svg+xml'},

      // 加载图片
      { test: /\.png$/, loader: "url-loader?limit=100000" },
      { test: /\.jpg$/, loader: "file-loader" },
      { test: /\.gif$/, loader: "file-loader" },

      // 用babel加载jsx
      {
        test: /\.jsx?$/,
        loader: 'babel',
        exclude: /node_modules/,
        query: {
          plugins: [
            [
              'react-transform',
              {
                transforms: [
                  {
                    transform: 'react-transform-hmr',
                    imports: ['react'],
                    locals: ['module'],
                  },
                ],
              },
            ],
          ],
        },
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader?importLoaders=1!postcss",
      },
      {
        test: /\.scss$/,
        loaders: [
          'style',
          'css?modules&importLoaders=3&localIdentName=[name]__[local]__[hash:base64:5]',
          'postcss',
          'sass',
          'sass-resources',
        ],
      },
      {
        test: require.resolve('jquery-ujs'),
        loader: 'imports?jQuery=jquery',
      },

      // Not all apps require jQuery. Many Rails apps do, such as those using TurboLinks or
      // bootstrap js
      { test: require.resolve('jquery'), loader: 'expose?jQuery' },
      { test: require.resolve('jquery'), loader: 'expose?$' },
      { test: /\.less$/, loader: "style!css!less" },
    ],
  },
};
