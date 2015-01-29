// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sass
//= require bootstrap.growl
//= require underscore
//= require underscore.string
//= require momentjs
//= require eonasdan-bootstrap-datetimepicker
//= require backbone
//= require backbone.modelbinder
//= require backbone.wreqr
//= require backbone.marionette
//= require tweenlite

//= require app/init
//= require_tree ../templates
//= require_tree ./app/routers
//= require_tree ./app/models
//= require_tree ./app/views
//= require_tree .


//default options for Bootstrap Growl
$.growl(false, {
  element: 'body',
  placement: {
    from: "bottom",
    align: "left"
  },
  delay: 10000,
});