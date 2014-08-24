console.log "main.js loaded"

main = $('.main')
main.find '.header'
.css 'background-color', 'orange'
.text "this is other text"
main.css 'opacity', '1'

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


