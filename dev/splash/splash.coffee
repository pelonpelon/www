console.log "splash.coffee loading"
window = this

main = document.getElementsByClassName('main')[0]
main.style.opacity = 0
main.classList.add 'fade'

splash = document.getElementsByClassName('splash')[0]
logo = splash.getElementsByClassName('logo')[0]
logo.style.opacity = 0
logo.classList.add 'fade'
window.setTimeout '1000'
logo.style.opacity = 1

# splash = document.getElementsByClassName('splash')[0]
# logo = splash.getElementsByClassName('logo')[0]
# logo.style.opacity = 0
# logo.classList.add 'fade'
# logo.style.opacity = 1

defer = (f)->
  if window.$
    console.log "jQuery loaded"
    f()
  else
    setTimeout ()->
      defer(f)
    ,50

downloadJSAtOnload = ->
  console.log "inside dl"

  element = document.createElement "link"
  # element.href = "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
  element.href = "lib/bootstrap.min.css"
  element.rel = "stylesheet"
  document.head.appendChild element

  # element = document.createElement "link"
  # element.href = "splash.css"
  # element.rel = "stylesheet"
  # document.head.appendChild element

  element = document.createElement "script"
  element.src = "lib/jquery.min.js"
  # element.src = "//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"
  document.body.appendChild element

  defer cb

cb = ->
  console.log "inside cb"

  main = $('.main')
  main.load "main.html"

  element = document.createElement "link"
  element.href = "main.css"
  element.rel = "stylesheet"
  document.head.appendChild element

  element = document.createElement "script"
  # element.src = "//cdnjs.cloudflare.com/ajax/libs/react/0.11.1/react.min.js"
  element.src = "lib/react.min.js"
  document.body.appendChild element

  element = document.createElement "script"
  element.src = "lib/react-bootstrap.min.js"
  document.body.appendChild element

  element = document.createElement "script"
  element.src = "main.js"
  document.body.appendChild element

if  window.addEventListener
  window.addEventListener "load", downloadJSAtOnload, false
else if  window.attachEvent
  window.attachEvent "onload", downloadJSAtOnload
else
  window.onload = downloadJSAtOnload

window.onload = ->
  console.log "splash.coffee loaded"
