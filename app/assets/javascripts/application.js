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
//= require uploadcare
//= require jquery-ui
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
//= require backbone-relational
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
//= require jquery.dotdotdot
//= require jquery.caret/dist/jquery.caret-1.5.2
//= require timeago
//= require x-editable/dist/bootstrap3-editable/js/bootstrap-editable
//= require DataTables
//= require bootstrap-switch
// require dataTables.bootstrap
//= require spinjs
//= require spinjs/jquery.spin.js
//= require ./lib/icheck

//= require_tree ./backbone/config
//= require backbone/init
//= require_tree ./backbone/routers
//= require_tree ./backbone/controllers
//= require_tree ./backbone/models
//= require_tree ./backbone/collections
//= require_tree ./backbone/layouts
//= require_tree ./backbone/components
//= require_tree ./backbone/modules

var ready;
ready = function() {
  //default options for Bootstrap Growl
  $.growl(false, {
    element: 'body',
    placement: {
      from: "top",
      align: "right"
    },
    delay: 10000,
  });

  $('html').click(function(e) {
    if ($(e.target).closest('form').length == 0) {
      $('.navbar-search-lg').hide();
      $('.navbar-search-sm').show();//.find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
      $('.progressjs-progress').hide();
    };
  });

  // default values for timeago widget
  $.timeago.settings.strings = {
    prefixAgo: null,
    prefixFromNow: null,
    suffixAgo: "ago",
    suffixFromNow: "from now",
    seconds: "about a minute",
    minute: "about a minute",
    minutes: "%d minutes",
    hour: "about an hour",
    hours: "about %d hours",
    day: "a day",
    days: "%d days",
    month: "about a month",
    months: "%d months",
    year: "about a year",
    years: "%d years",
    wordSeparator: " ",
    numbers: []
  };
  //end default values for timeago widget

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
  //end trimming space from both side of the string
  
  /**
   * Indicates whether or not this string starts with the specified string.
   * @param {Object} string
   */
  String.prototype.startsWith = function(string){
      if (!string) 
          return false;
      return this.indexOf(string) == 0;
  }
  
  Marionette.Behaviors.behaviorsLookup = function() {
    return window.Behaviors;
  }
};

$(window).on('scroll', function() {
  scrollPosition = $(this).scrollTop();
  if (scrollPosition >= 1) { 
      $('.nav').addClass('fixedscroll'); 
  }else{
      $('.nav').removeClass('fixedscroll'); 
  }
});

$(document).ready(ready);
$(document).on('page:load', ready);
