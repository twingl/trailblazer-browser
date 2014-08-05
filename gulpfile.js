var gulp    = require('gulp')
  , spawn   = require('child_process').spawn
  , es      = require('event-stream')

    // Assets
  , handlebars  = require('gulp-ember-handlebars')
  , coffee      = require('gulp-coffee')
  , sass        = require('gulp-sass')

    // Compilation
  , clean         = require('gulp-clean')
  , concat        = require('gulp-concat')
  , cssmin        = require('gulp-cssmin')
  , declare       = require('gulp-declare')
  , defineModule  = require('gulp-define-module')
  , uglify        = require('gulp-uglify')
  , util          = require('gulp-util')
  , watch         = require('gulp-watch')
  , zip           = require('gulp-zip');





/*------------*\
 * Main Tasks *
\*------------*/

gulp.task('default', ['watch']);


/**
 * Assemble the app when the source is modified
 */
gulp.task('autobuild', function () {
  gulp.watch(locations.src.templates, ['assemble']);
  gulp.watch(locations.src.styles,    ['assemble']);
  gulp.watch(locations.src.scripts,   ['assemble']);
});


/**
 * Automatically run specs when scripts are changed
 */
gulp.task('watch', function () {
  gulp.watch(locations.src.templates, ['spec']);
  gulp.watch(locations.src.scripts,   ['spec']);
});


/**
 * Compile the source files into tmp/
 */
gulp.task('compile', ['clean'], function () {
  return gulp.start('templates', 'styles', 'scripts');
});


/**
 * Assemble the Application, ready to load into Chrome
 */
gulp.task('assemble', ['compile'], function () {
  return gulp.start('copy');
});



/**
 * Run all of the necessary steps to build the app, ready for deployment
 */
gulp.task('release', ['compile', 'copy', 'assemble'], function () {
  return gulp.start('package');
});


var files = {
  templates   : 'app.hbs.min.js',
  styles      : 'app.min.css',
  scripts     : 'app.min.js',
  packagedApp : 'trailblazer',
  manifest    : './APP_ROOT/manifest'
}

var locations = {
  // Development source - the ones you should be editing
  src: {
    templates : [ 'templates/**/*.hbs' ],
    styles    : [ 'styles/**/*.scss' ],
    scripts   : [
      'app/initializers/**/*.coffee',
      'app/boot.coffee',
      'app/adapters/**/*.coffee',
      'app/models/**/*.coffee',
      'app/controllers/**/*.coffee',
      'app/views/**/*.coffee',
      'app/routes/**/*.coffee',
      'app/router.coffee',
      'app/main.coffee'
    ]
  },

  // Intermediate location for compiled source
  build: {
    templates : 'tmp/templates',
    styles    : 'tmp/styles',
    scripts   : 'tmp/scripts'
  },

  // Location of the source in the Chrome app source tree
  release: {
    templates : 'APP_ROOT/templates',
    styles    : 'APP_ROOT/styles',
    scripts   : 'APP_ROOT/scripts'
  },

  pkgTarget: 'APP_ROOT/**/*',
  releaseDir: 'release'
};

var toClean = [
                'tmp/*',
                locations.release.templates + '/' + files.templates,
                locations.release.styles + '/' + files.styles,
                locations.release.scripts + '/' + files.scripts
              ];


/*------------------*\
 * Supporting Tasks *
\*------------------*/

/**
 * Run the specs for the project
 */
gulp.task('spec', function () {
  return util.log(util.colors.yellow("Spec not yet implemented"));
});


/**
 * Cleans up remnants from the previous compilation
 */
gulp.task('clean', function () {
  var streams = [];
  for (var i = 0; i < toClean.length; i += 1) {
    util.log("Removing", "'" + util.colors.red(toClean[i]) + "'");
    streams.push(gulp.src(toClean[i], { read: false }).pipe(clean()));
  }
  return es.merge.apply(this, streams);
});


/**
 * Compile all HBS templates used in the app
 */
gulp.task('templates', function () {
  return gulp.src(locations.src.templates)
      .pipe(handlebars({ outputType: 'browser'}))
      .pipe(uglify())
      .pipe(concat(files.templates))
      .pipe(gulp.dest(locations.build.templates))
});


/**
 * Compile and concatenate the stylesheets used in the project, ready for
 * inclusion in the packaged app
 */
gulp.task('styles', function () {
  return gulp.src(locations.src.styles)
      .pipe(sass())
      .pipe(cssmin())
      .pipe(concat(files.styles))
      .pipe(gulp.dest(locations.build.styles));
});


/**
 * Compile, uglify, and concatenate the scripts used in the project, ready for
 * inclusion in the packaged app
 */
gulp.task('scripts', function () {
  return gulp.src(locations.src.scripts)
      .pipe(coffee())
      .pipe(uglify())
      .pipe(concat(files.scripts))
      .pipe(gulp.dest(locations.build.scripts));
});


/**
 * Copy the compiled sources into their intended location in the app
 */
gulp.task('copy', ['templates','styles','scripts'], function () {
  return es.merge(
    gulp.src(locations.build.styles + '/' + files.styles)
        .pipe(gulp.dest(locations.release.styles)),

    gulp.src(locations.build.scripts + '/' + files.scripts)
        .pipe(gulp.dest(locations.release.scripts)),

    gulp.src(locations.build.templates + '/' + files.templates)
        .pipe(gulp.dest(locations.release.templates)));
});


/**
 * Packages APP_DIR into a zip archive, ready for deployment on the Chrome Web
 * Store
 */
gulp.task('package', function () {
  var manifest = require(files.manifest)
    , pkgName  = files.packagedApp + "-" + manifest.version + ".zip"

  util.log("Packaging", "'" + util.colors.yellow(locations.releaseDir + "/" + pkgName) + "'");

  return gulp.src(locations.pkgTarget)
      .pipe(zip(pkgName))
      .pipe(gulp.dest(locations.releaseDir));
});
