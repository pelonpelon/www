console.log "loading splash.coffee"
window = this

defer = (f)->
  if window.$
    console.log "jQuery loaded"
    console.log typeof f
    f()
  else
    setTimeout ()->
      defer(f)
    ,50

downloadJSAtOnload = ->
  console.log "inside dl"

  element = document.createElement "script"
  element.src = "//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"
  document.body.appendChild element

  defer cb

cb = ->
  console.log "inside cb"
  container = $('#container')
  container.addClass "main"
  # container.contents().remove()
  container.load "main.html"

  element = document.createElement "script"
  element.src = "main.js"
  document.body.appendChild element

  element = document.createElement "link"
  element.href = "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
  element.rel = "stylesheet"
  document.head.appendChild element

if  window.addEventListener
  window.addEventListener "load", downloadJSAtOnload, false
else if  window.attachEvent
  window.attachEvent "onload", downloadJSAtOnload
else
  window.onload = downloadJSAtOnload

window.onload = ->
  console.log "splash.coffee loaded"
