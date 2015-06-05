//= require jquery
//= require bootstrap-sass
//= require ./lib/jquery.adaptive-backgrounds
//= require_self

$(document).ready(function(){
  $.adaptiveBackground.run({
    parent:'.story', 
    normalizeTextColor: true
  });
});
