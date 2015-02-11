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
//= require bootstrap-sweetalert
//= require uploadcare
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
//= require backbone
//= require backbone.babysitter
//= require backbone.modelbinder
//= require backbone.wreqr
//= require backbone.marionette
//= require tweenlite
//= require highcharts
//= require select2
//= require_directory ./lib

//= require_tree ../templates
//= require_tree ./backbone/config
//= require backbone/init
//= require_tree ./backbone/models
//= require_tree ./backbone/collections
//= require_tree ./backbone/layouts
//= require_tree ./backbone/modules

// require app/init
// require_tree ../templates
// require_tree ./app/routers
// require_tree ./app/models
// require_tree ./app/views
// require_tree .

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
  //end default options for Bootstrap Growl

  // load the SDK Asynchronously
  window.fbAsyncInit = function() {
    FB.init({
      appId      : window.fb_api_key, //need change id
      xfbml      : true,
      version    : 'v2.2'
    });
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));
  // end load the SDK Asynchronously

  // load Google+ sdk
  (function() {
    var po = document.createElement('script');
    po.type = 'text/javascript'; po.async = true;
    po.src = 'https://plus.google.com/js/client:plusone.js';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(po, s);
  })()
  // end load Google+ sdk
  $('html').click(function(e) {
    if ($(e.target).closest('form').length == 0) {
      $('.navbar-search-lg').hide();
      $('.navbar-search-sm').show()//.find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
      $('.progressjs-progress').hide();
    };
  });

  // Navigation
  $(document).on("click", '#sidebar li a', function(e) {
    $('#sidebar li.active').removeClass('active');
    $(this).parent().addClass('active');
    var tab = $(this).attr('id').replace('nav-','');
    $('.page-content').html(_.template($('#_'+tab).text(),{}));
  });
  // End Navigation

};

$(document).ready(ready);
$(document).on('page:load', ready);