'use strict'
# Paths
root = './'
dev = root + 'dev/'
app = root + 'app/'
dist = root + 'dist/'

gulp        = require 'gulp'
gulpif      = require 'gulp-if'
gutil       = require 'gulp-util'
gp          = (require 'gulp-load-plugins') lazy: false, camelize: true
path        = require 'path'
browserify  = require 'browserify'
source      = require 'vinyl-source-stream'
stylus      = require 'gulp-stylus'
sprites     = require('css-sprite').stream
# sprite = require 'gulp-sprite-generator'



# HTML
gulp.task 'html', ->
  gulp.src dev+'index.jade'
    .pipe gp.plumber()
    .pipe gp.jade(
      locals:
        pageTitle: 'Polymous'
    )
    .pipe gulp.dest app

# JS
gulp.task 'js', ->
  gulp.src dev+'main.coffee'
  .pipe gp.plumber()
  browserify
    entries: [dev+'main.coffee']
    extensions: ['.coffee', '.js']
  .transform 'coffeeify'
  .transform 'deamdify'
  .transform 'debowerify'
  .bundle()
  .pipe source 'main.js'
  .pipe gulp.dest app

# CSS
gulp.task 'css', ->
  gulp.src dev+'main.styl'
    .pipe gp.stylus
      'include css': true
    .pipe gp.autoprefixer 'last 1 version'
    .pipe gulp.dest app

# Polymer components
gulp.task 'components', ->
  gulp.src dev+'components/components.jade'
    .pipe gp.plumber()
    .pipe gp.jade()
    .pipe gulp.dest app
  gulp.src app+'components/components.jade'
    .pipe gp.vulcanize
      dest: app
    .pipe gulp.dest app

#gulp.task 'img', ->
#  gulp.src [dev+'content/spritesrc/*']
#    .pipe gulp.dest app+'content/spritesrc/'
#  spriteOutput = gulp.src app+'main.css'
#    .pipe sprite({
#      baseUrl:         '../dev'
#      spriteSheetName: 'sprite.png'
#      spriteSheetPath: './'
#      styleSheetName: '_sprite.css'
#    })
#  spriteOutput.css.pipe gulp.dest app
#  spriteOutput.img.pipe gulp.dest app

# Images
gulp.task 'img', ->
  gulp.src [dev+'content/images/*.jpg',
           dev+'content/images/*.jpeg',
           dev+'content/images/*.png',
           dev+'content/images/*.svg',
           dev+'content/images/*.gif']
    .pipe gp.cache gp.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest app+'content/images'
  gulp.src dev+'content/spritesrc/*.png'
    .pipe gp.cache gp.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest dev+'content/spritesrc'
  gulp.src dev+'content/spritesrc/*.png'
    .pipe sprites({
      name: 'sprite.png'
      style: '_sprite.styl'
      cssPath: './content/images'
      processor: 'stylus'
    })
    .pipe gulpif('*.png', gulp.dest app+'content/images')
    .pipe gulpif('*.styl', gulp.dest dev+'css')
#
# Clean
gulp.task 'clean', ->
  gulp.src ['app', 'tmp'], read: false
    .pipe gp.clean force: true

# Build
gulp.task 'build', ['html', 'components', 'js', 'css', 'img']

# Dist
gulp.task 'dist', ['build'], ->
  browserify
    entries: [dev+'main.coffee']
    extensions: ['.coffee', '.js']
  .transform 'coffeeify'
  .transform 'deamdify'
  .transform 'debowerify'
  .transform 'uglifyify'
  .bundle()
  # Pass desired file name to browserify with vinyl
  .pipe source 'main.js'
  # Start piping stream to tasks!
  .pipe gulp.dest dist

# Default task
gulp.task 'default', ['clean'], -> gulp.start 'build'

# Connect
gulp.task 'connect', ['default'], ->
  gp.connect.server
    root: app
    port: 9000
    livereload: true

# Watch
gulp.task 'watch', ['connect'], ->
  gulp.watch [dev+'**/*'], read:false, (event) ->
    ext = path.extname event.path
    taskname = null
    reloadasset = null
    switch ext
      when '.jade', '.md'
        taskname = 'html'
        reloadasset = app+'index.html'
      when '.styl'
        taskname = 'css'
        reloadasset = app+'main.css'
      when '.coffee', '.js'
        taskname = 'js'
        reloadasset = app+'main.js'
      else
        taskname = 'img'
        reloadasset = app+"images/#{path.basename event.path}"
    gulp.task 'reload', [taskname], ->
      gulp.src reloadasset
        .pipe gp.connect.reload()
    gulp.start 'reload'

gulp.task 'splashjade', ->
    gulp.src [dev+'splash.jade']
      .pipe gp.plumber()
      .pipe gp.jade locals: pageTitle: 'Splash'
      .pipe source "index.html"
      .pipe gulp.dest app
# Splash and watch
gulp.task 'splash', ->
  gp.connect.server
    root: app
    port: 9000
    livereload: true
  gulp.watch dev+'splash.jade', read:false, (event) ->
    gulp.task 'reload', ['splashjade'], ->
      gp.connect.reload()
    gulp.start 'reload'

