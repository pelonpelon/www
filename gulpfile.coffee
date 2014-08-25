'use strict'

gulp        = require 'gulp'
gulpif      = require 'gulp-if'
gutil       = require 'gulp-util'
cat         = require 'gulp-cat'
colors      = gutil.colors
path        = require 'path'
prepend     = require 'prepend-file'
gp          = (require 'gulp-load-plugins') lazy: false, camelize: true
through     = require 'through'
src      = require 'vinyl-source-stream'
runSequence = require 'run-sequence'
rsync       = require('rsyncwrapper').rsync
browserify  = require 'browserify'
coffee      = require 'gulp-coffee'
stylus      = require 'gulp-stylus'
sprite     = require('css-sprite').stream
log=gutil.log

gulp.env['development'] = true
log gulp.env.development

config      = require './.config'
devDir = config.devDir || 'dev/'
splashDir = devDir+'splash/'
buildDir = config.buildDir || 'build/development/'
prodDir = config.prodDir || 'build/production/'

# Splash
gulp.task 'splash-stylus', ->
  gulp.src splashDir+'splash.styl'
    .pipe stylus(
      'include css': true
      errors: true
    )
    .pipe gp.autoprefixer '> 1%', 'last 6 version', 'ff 17', 'opera 12.1', 'ios >= 5'
    .pipe gulp.dest devDir+"splash"
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)
gulp.task 'splash-coffee', ->
  gulp.src splashDir+'splash.coffee'
    .pipe coffee(
      bare:true
    )
    .pipe gulp.dest devDir+"splash"
gulp.task 'splash-jade', ->
  gulp.src splashDir+'splash.jade'
    .pipe gp.plumber()
    .pipe gulpif(gulp.env.development,
      gp.jade
        locals:
          pageTitle: config.pageTitle || 'MyApp'
        pretty: true
    )
    .pipe gulpif(!gulp.env.development,
      gp.jade
        locals:
          pageTitle: config.pageTitle || 'MyApp'
    )
    .pipe gp.rename 'index.html'
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

gulp.task 'splash', (cb)->
  runSequence ['splash-stylus', 'splash-coffee'], 'splash-jade', cb

# jade
gulp.task 'jade', ->
  gulp.src devDir+'main.jade', base: devDir
    .pipe gp.plumber()
    .pipe gulpif(gulp.env.development,
      gp.jade
        locals:
          pageTitle: config.pageTitle || 'MyApp'
        pretty: true
    )
    .pipe gulpif(!gulp.env.development,
      gp.jade
        locals:
          pageTitle: config.pageTitle || 'MyApp'
    )
    .pipe gp.rename 'main.html'
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

# coffee
gulp.task 'coffee', ->
  gulp.src devDir+'main.coffee'
    .pipe coffee(
      bare: true
    ).on 'error', gutil.log
    .pipe(if !gulp.env.development then gp.uglify() else gutil.noop())
    .pipe gp.rename 'main.js'
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

# React
gulp.task 'react', ->
  gulp.src devDir+'components/**/*.coffee'
    .pipe coffee(
      bare: true
    ).on 'error', gutil.log
    .pipe gp.rename
      extname: ".jsx"
    .pipe gulp.dest devDir+'components'
  gulp.src devDir+'components/**/*.jsx', base: devDir
    .pipe gp.react()
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

# stylus
gulp.task 'stylus', ->
  gulp.src devDir+'main.styl', base: devDir
    .pipe gp.stylus
      'include css': true
      errors: true
    .pipe gp.autoprefixer '> 1%', 'last 6 version', 'ff 17', 'opera 12.1', 'ios >= 5'
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

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
    .pipe gulpif(gulp.env.development, gulp.dest buildDir+'content/images')
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir+'content/images')
  cb()

# Images
gulp.task 'img', ['mksprite'], (cb)->
  gulp.src [devDir+'content/images/**/*.{jpg,jpeg,png,svg,gif}'], base: devDir
    .pipe gp.cache gp.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)
  cb()

# copy libs
gulp.task 'copylibs', ->
  gulp.src [devDir+'lib/**/*.*'], base: devDir
    .pipe gulpif(gulp.env.development, gulp.dest buildDir)
    .pipe gulpif(!gulp.env.development, gulp.dest prodDir)

# Clean
gulp.task 'clean', ->
  gulp.src [buildDir, prodDir, 'tmp'], read: false
    .pipe gp.clean force: true

# Build
gulp.task 'build', ['clean'], (cb)->
  runSequence 'copylibs', 'img', 'splash', 'stylus', 'coffee', 'react', 'jade', cb

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

gulp.task 'rsynclab', ->
  remotePath = config.labRemotePath
  log remotePath
  rsync
    ssh: true
    src: prodDir
    dest: 'sfeagleftp@sf-eagle.com:'+remotePath
    recursive: true
    syncDest: true
    args: ['--verbose']
  , (error, stdout, stderr, cmd)->
      gutil.log stdout

gulp.task 'rsyncwww', ->
  remotePath = config.wwwRemotePath
  log remotePath
  rsync
    ssh: true
    src: prodDir
    dest: 'sfeagleftp@sf-eagle.com:'+remotePath
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
  log 'task: connect'
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
  log "task: livereload"
  livereload.listen()
  gulp.watch(devDir+'**').on 'change', livereload.changed

# Watch
gulp.task 'watch', ['connect'], ->
  gulp.watch [devDir+'**/*'], read:false, (event) ->
    fullpath = event.path
    dir = (path.dirname event.path).match(/([^\/]*)\/*$/)[1]
    file = path.basename event.path
    if file is 'tags'
      return
    ext = path.extname event.path
    log 'path: '+fullpath
    # log 'dir: '+dir
    # log 'file: '+file
    # log 'ext: '+ext
    if (path.basename event.path).match(/_.*$/)
      log 'watch: skipping '+file
      return
    taskname = null
    reloadasset = null
    if dir is 'splash'
      # log 'splash changes'
      switch ext
        # when '.css', '.js', '.html'
          # log 'watch: skipping '+file
          # return
        when '.jade'
          task1 = 'splash'
          reloadasset = buildDir+'index.html'
          log "calling task: splash-jade"
        when '.styl'
          task1 = 'splash'
          task2 = 'stylus'
          reloadasset = "[splashDir+'splash.css', buildDir+'main.css']"
          log "calling task: splash-styl"
        when '.coffee'
          task1 = 'splash'
          reloadasset = "[splashDir+'splash.js', buildDir+'main.js']"
          log "calling task: splash-coffee"
        when '.jpg', '.jpeg', '.png', '.gif'
          task1 = 'img'
          reloadasset = splashDir+"images/#{path.basename event.path}"
          log "calling task: img"
        else
          return
    else
      # log 'dev changes'
      switch ext
        # when '.css', '.js', '.html'
          # log 'watch: skipping '+file
          # return
        when '.jade'
          task1 = 'jade'
          reloadasset = buildDir+'index.html'
        when '.styl'
          task1 = 'stylus'
          reloadasset = buildDir+'index.html'
        when '.coffee', '.js'
          task1 = 'coffee'
          task2 = 'react'
          reloadasset = buildDir+'index.html'
        when '.jsx'
          task1 = 'react'
          reloadasset = buildDir+'index.html'
        when '.jpg', '.jpeg', '.png', '.gif'
          task1 = 'img'
          reloadasset = splashDir+"images/#{path.basename event.path}"
          log "calling task: img"
        else
          return
    gulp.task 'reload', [task1], ->
      if task2
        runSequence task2
      log "reloading: "+reloadasset
      gulp.src reloadasset
        .pipe gp.connect.reload()
    gulp.start 'reload'
    log '----------------------------------'

      # gp.browserify
        # debug: gulp.env.development
        # transform: [ 'coffeeify', 'debowerify', 'deamdify' ]
        # extensions: ['.coffee']
    # )
    # .pipe gulpif(!gulp.env.development,
      # gp.browserify
        # transform: [ 'coffeeify', 'debowerify', 'deamdify' ]
        # extensions: ['.coffee']
      # gp.uglify()
    # )
