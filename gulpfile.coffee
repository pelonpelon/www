'use strict'

gulp        = require 'gulp'
gulpif      = require 'gulp-if'
gutil       = require 'gulp-util'
colors      = gutil.colors
path        = require 'path'
prepend     = require 'prepend-file'
gp          = (require 'gulp-load-plugins') lazy: false, camelize: true
through     = require 'through'
source      = require 'vinyl-source-stream'
runSequence = require 'run-sequence'
rsync       = require('rsyncwrapper').rsync
browserify  = require 'browserify'
sprite     = require('css-sprite').stream
# log=gutil.log

# Splash
gulp.task 'splash', ->
  gulp.src './splash.coffee'
    .pipe gp.changed './'
    .pipe gp.coffee()
    .pipe gp.rename 'splash.js'
    .pipe gulp.dest './'
gulp.start 'splash'
splash      = require './splash.js'
log         = splash.log
# Splash config file
config      = require './.config'

env = process.env.NODE_ENV || 'development'
devDir = config.devDir || 'dev/'
buildDir = config.buildDir || 'build/development/'
prodDir = config.prodDir || 'build/production/'

# jade
gulp.task 'jade', ->
  gulp.src devDir+'index.jade', base: devDir
    .pipe gp.plumber()
    .pipe gp.jade(
      locals:
        pageTitle: config.pageTitle || 'Splash'
    )
    .pipe gulpif(env == 'development', gp.changed buildDir)
    .pipe gulpif(env == 'production', gp.changed prodDir)
    .pipe gulpif(env == 'development', gulp.dest buildDir)
    .pipe gulpif(env == 'production', gulp.dest prodDir)

# coffee
gulp.task 'coffee', ->
  gulp.src devDir+'main.coffee', read: false, base: devDir
    .pipe gp.browserify
      debug: env == 'development'
      transform: [ 'coffeeify', 'debowerify', 'deamdify' ]
      extensions: ['.coffee']
    .pipe gulpif env == 'production', gp.uglify()
    .pipe gp.rename 'main.js'
    .pipe gulpif(env == 'development', gp.changed buildDir)
    .pipe gulpif(env == 'production', gp.changed prodDir)
    .pipe gulpif(env == 'development', gulp.dest buildDir)
    .pipe gulpif(env == 'production', gulp.dest prodDir)

#js
#gulp.task 'js', ->
#  browserify 'main.js'
#    .bundle
#      debug: true
#    .pipe source bundle.js
#    .pipe gp.srteamify gp.uglify()
#    .pipe gulp.dest buildDir



# stylus
gulp.task 'stylus', ->
  gulp.src devDir+'main.styl', base: devDir
    .pipe gp.stylus
      'include css': true
      errors: true
    .pipe gp.autoprefixer 'last 1 version'
    .pipe gulpif(env == 'development', gp.changed buildDir)
    .pipe gulpif(env == 'production', gp.changed prodDir)
    .pipe gulpif(env == 'development', gulp.dest buildDir)
    .pipe gulpif(env == 'production', gulp.dest prodDir)

# Polymer components
#gulp.task 'components', ->
#  gulp.src devDir+'components/components.jade'
#    .pipe gp.plumber()
#    .pipe gp.jade()
#    .pipe gulp.dest buildDir
#  gulp.src buildDir+'components/components.jade'
#    .pipe gp.vulcanize
#      dest: buildDir
#    .pipe gulp.dest buildDir

# Make Sprite
gulp.task 'mksprite', (cb)->
  gulp.src devDir+'content/spritesrc/*.png'
    .pipe sprite
      name: 'sprite.png'
      style: '_sprite.styl'
      cssPath: '../content/images'
      processor: 'stylus'
    .pipe gp.tap (file, t)->
      if path.extname(file.path) == '.styl'
        prepend devDir+'main.styl', '@import "css/*"\n', (done)->
          if done
            log done + ': @import css/* prepended to main.styl'
    .pipe gulpif('*.styl', gulp.dest devDir+'css')
    .pipe gulpif('*.styl', gp.ignore.exclude '*.styl')
    .pipe gulpif(env == 'development', gp.changed buildDir+'content/images')
    .pipe gulpif(env == 'production', gp.changed prodDir+'content/images')
    .pipe gulpif(env == 'development', gulp.dest buildDir+'content/images')
    .pipe gulpif(env == 'production', gulp.dest prodDir+'content/images')
  cb()

# Images
gulp.task 'img', ['mksprite'], (cb)->
  gulp.src [devDir+'content/images/**/*.{jpg,jpeg,png,svg,gif}'], base: devDir+'content/images'
    .pipe gp.cache gp.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulpif(env == 'development', gp.changed buildDir+'content/images')
    .pipe gulpif(env == 'production', gp.changed prodDir+'content/images')
    .pipe gulpif(env == 'development', gulp.dest buildDir+'content/images')
    .pipe gulpif(env == 'production', gulp.dest prodDir+'content/images')
  cb()

# copy libs
gulp.task 'copylibs', ->
  gulp.src [devDir+'lib/**/*.*'], base: devDir+'lib/'
    .pipe gulpif(env == 'development', gp.changed buildDir+'lib')
    .pipe gulpif(env == 'production', gp.changed prodDir+'lib')
    .pipe gulpif(env == 'development', gulp.dest buildDir+'lib')
    .pipe gulpif(env == 'production', gulp.dest prodDir+'lib')

# Clean
gulp.task 'clean', ->
  gulp.src [buildDir, prodDir, 'tmp'], read: false
    .pipe gp.clean force: true

# Build
gulp.task 'build', ['splash', 'clean'], (cb)->
  runSequence ['copylibs', 'jade', 'coffee'], 'img', 'stylus', cb

# Dist
gulp.task 'dist', (cb)->
  env = 'production'
  runSequence 'build'
  cb()

# Upload to server
#gulp.task 'upload', (callback)->
#  gulp.src prodDir+'/**/*',
#    baseUrl: './'
#    buffer: false
#  .pipe gp.sftp
#    host: config.host
#    username: config.username
#    remotePath: config.remotePath

gulp.task 'rsync', ->
  rsync
    ssh: true
    src: prodDir
    dest: 'sfeagleftp@sf-eagle.com:'+config.remotePath
    recursive: true
    syncDest: true
    args: ['--verbose']
  , (error, stdout, stderr, cmd)->
      gutil.log stdout

# Default task
gulp.task 'default', ['build'], (cb)->
  runSequence 'watch', cb

# Connect
gulp.task 'connect', ->
  gp.connect.server
    root: buildDir
    port: 9000
    livereload: true

# Webserver
gulp.task 'webserver', ->
  gulp.src buildDir
    .pipe gp.webserver
      livereload: true
      directoryListing: true
      port: 2000

# livereload
gulp.task 'livereload', ->
  livereload.listen()
  gulp.watch(devDir+'**').on 'change', livereload.changed

# Watch
gulp.task 'watch', ['connect'], ->
  gulp.watch [devDir+'**/*'], read:false, (event) ->
    ext = path.extname event.path
    taskname = null
    reloadasset = null
    switch ext
      when '.jade'
        taskname = 'jade'
        reloadasset = buildDir+'index.html'
      when '.styl'
        taskname = 'stylus'
        reloadasset = buildDir+'main.css'
      when '.coffee', '.js'
        taskname = 'coffee'
        reloadasset = buildDir+'main.js'
      else
        taskname = 'img'
        reloadasset = buildDir+"images/#{path.basename event.path}"
    gulp.task 'reload', [taskname], ->
      gulp.src reloadasset
        .pipe gp.connect.reload()
    gulp.start 'reload'
    log '----------------------------------'
