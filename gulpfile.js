var gulp = require('gulp');
var webpack = require('webpack-stream');

var webpackConfig = require('./webpack.config.js');

gulp.task('default', ['webpack-dev']);

gulp.task('static-dev', function() {
  return gulp.src(['./css/*', './fonts/*', './js/*', './index.html'],
                  {base: './'})
    .pipe(gulp.dest('test_dist/'));
});

gulp.task('webpack-dev', function() {
  webpackConfig.devtool = 'source-map';
  webpackConfig.watch = true;

  return gulp.src('scripts/main.js')
    .pipe(webpack(webpackConfig))
  /*
    .pipe(webpack(webpackConfig, null,
                  function(err, stats) {
                    console.log(stats);
                  }))
   */
    .pipe(gulp.dest('test_dist/'));
});

gulp.task('webpack-prod', function() {
  webpackConfig.plugins = webpackConfig.plugins.concat(
    new webpack.webpack.DefinePlugin({
      "process.env": {
	// This has effect on the react lib size
	"NODE_ENV": JSON.stringify("production")
      }
    }),
    new webpack.webpack.optimize.DedupePlugin(),
    new webpack.webpack.optimize.UglifyJsPlugin()
  );

  // XXX Use a hash.
  return gulp.src('scripts/main.js')
    .pipe(webpack(webpackConfig))
    .pipe(gulp.dest('dist/'));
});
