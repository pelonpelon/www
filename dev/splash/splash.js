var cb, defer, downloadJSAtOnload, window;

console.log("loading splash.coffee");

window = this;

defer = function(f) {
  if (window.$) {
    console.log("jQuery loaded");
    console.log(typeof f);
    return f();
  } else {
    return setTimeout(function() {
      return defer(f);
    }, 50);
  }
};

downloadJSAtOnload = function() {
  var element;
  console.log("inside dl");
  element = document.createElement("script");
  element.src = "//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js";
  document.body.appendChild(element);
  return defer(cb);
};

cb = function() {
  var container, element;
  console.log("inside cb");
  container = $('#container');
  container.addClass("main");
  container.load("main.html");
  element = document.createElement("script");
  element.src = "main.js";
  return document.body.appendChild(element);
};

if (window.addEventListener) {
  window.addEventListener("load", downloadJSAtOnload, false);
} else if (window.attachEvent) {
  window.attachEvent("onload", downloadJSAtOnload);
} else {
  window.onload = downloadJSAtOnload;
}

window.onload = function() {
  return console.log("splash.coffee loaded");
};
