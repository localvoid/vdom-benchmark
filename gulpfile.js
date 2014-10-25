'use strict';

var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var del = require('del');

var SRC = 'js';
var OUT = 'web/js';

gulp.task('scripts', function () {
  return gulp.src(SRC + '/*.js')
    .pipe($.browserify())
    .pipe($.uglify())
    .pipe(gulp.dest(OUT))
    .pipe($.size({title: 'scripts'}));
});

gulp.task('clean', del.bind(null, [OUT]));

gulp.task('default', ['clean', 'scripts']);
