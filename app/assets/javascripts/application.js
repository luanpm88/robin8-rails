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
//= require assets
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require uploadcare
//= require jqueryui
//= require bootstrap-sass
//= require bootstrap-sweetalert
//= require progressjs
//= require blueimp-gallery
// require bootstrap3-wysihtml5-bower
//= require bootstrap-sweetalert
//= require bootstrap.growl
//= require underscore
//= require underscore.string
//= require momentjs
//= require eonasdan-bootstrap-datetimepicker
//= require chance
//= require please-wait
//= require backbone
//= require backbone.babysitter
//= require backbone.modelbinder
//= require backbone.wreqr
//= require backbone.marionette
//= require highcharts
//= require select2
//= require_directory ./lib
//= require bootstrap-tagsinput
//= require ./lib/formValidation/formValidation.min
//= require ./lib/formValidation/js/bootstrap.min
//= require bootstrap-wysihtml5

//= require_tree ./backbone/config
//= require backbone/init
//= require_tree ./backbone/routers
//= require_tree ./backbone/controllers
//= require_tree ./backbone/models
//= require_tree ./backbone/collections
//= require_tree ./backbone/layouts
//= require_tree ./backbone/modules

var ready;
ready = function() {
  
  //default options for Bootstrap Growl
  $.growl(false, {
    element: 'body',
    placement: {
      from: "bottom",
      align: "left"
    },
    delay: 10000,
  });

  $('html').click(function(e) {
    if ($(e.target).closest('form').length == 0) {
      $('.navbar-search-lg').hide();
      $('.navbar-search-sm').show()//.find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
      $('.progressjs-progress').hide();
    };
  });

  //trimming space from both side of the string
  String.prototype.normalizeRSpace = function(len) {
    if (this.length == 0) {
      return this;
    }
    if (this.length > len) {
      return this.substring(0, len) + '...';
    } else {
      return this + new Array(len - this.length).join(' ');
    }
  }
};

$(document).ready(ready);
$(document).on('page:load', ready);
