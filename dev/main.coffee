'use strict'

# require 'gsap/src/minified/plugins/CSSPlugin.min.js'
# require 'gsap/src/minified/easing/EasePack.min.js'
# require 'gsap/src/minified/TweenLite.min.js'

Engine         = require 'famous/core/Engine.js'
Context        = require 'famous/core/Context.js'
Surface        = require 'famous/core/Surface.js'
Modifier       = require 'famous/core/Modifier.js'
Transform      = require 'famous/core/Transform.js'
Tween          = require 'famous/transitions/TweenTransition.js'
Transitionable = require 'famous/transitions/Transitionable.js'

app = document.createElement 'div'
app.id = 'app'
#app.classList.add 'logo'
window.document.body.appendChild app

ctx = Engine.createContext(app)

logo = new Surface
  size: [200, 200]
  origin: [0.5,0.5]
  classes: "logo"

rotateMod = new Modifier
  origin: [0.5,0.5]
  transform: Transform.rotateY 0

Transitionable.registerMethod 'tween', Tween
t = new Transitionable 0

rotateMod.transformFrom ->
  Transform.rotateY t.get()

transition =
  method: 'tween'
  curve: 'easeInOut'
  duration: '1500'

t.set Math.PI/2, transition
t.set 0, transition

ctx.add rotateMod
.add logo




# window.onload = ->
# console.log "loaded"
# container = document.getElementById 'container'
# # container.addEventListener "click", (evt)->
  # # console.log evt.target.id
  # # evt.target.style.transform = 'translateZ(0)'
  # # if evt.target.style.transform != 'none'
    # # window.setTimeout (=>
      # # evt.target.style.transform = "none"
      # # console.log "times up"
      # # ), 2000
# box2 = box.cloneNode true
# box2.style.background = "orange"
# box2.style.width = "250px"
# box2.style.height = "250px"
# container.appendChild box2
# box.style.transform = 'translateZ(0)'
# m = new TweenLite.to(box)
# console.log m
# m.duration 1
# m.paused true
# m.vars =
  # width: "400px"
  # height: "400px"
# m.resume()


