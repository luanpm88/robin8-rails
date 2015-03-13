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
//= require jquery-ui
//= require ./lib/foundation.min
//= require ./lib/modernizr

function setSizes(){
  $('.sizeheader').css('height',$(window).height()); 

  var signuplogomargin = $(window).height()/2 - 80;
  $('.sizeheader .logo').css('margin-top',signuplogomargin + 'px');

  var logomargin = $(window).height()/2 - 140;
  $('.homeheader .logo').css('margin-top',logomargin + 'px');

  var bgposition = $(window).width()/2;
  $('.screenpane').css('background-position', bgposition + 'px bottom');
}

var ready;
ready = function() {
  // $(document).foundation();

  //app.js from new ui

  /* SET SIZES FOR LEADERBOARDS */
  setSizes();


  /* HOMEPAGE SCROLL BUTTON */
  $( ".learn-more" ).click(function() {
    $('html, body').animate({
        scrollTop: $(window).height()
     }, 600);
  });

  /* STEP 2 functions */

  $('.business-plans').show();

  $('.agency-plans').hide();


  $( "#selected-businesses" ).click(function() {
    if(!$(this).is('active')){
      $('.agency-plans').fadeOut();
      setTimeout(function(){ $('.business-plans').fadeIn();}, 500);
      $('.tab-nav a').removeClass('active');
      $(this).addClass('active'); 
    }
  });
  $( "#selected-agencies" ).click(function() {
    if(!$(this).is('active')){
      $('.business-plans').fadeOut(); 
      setTimeout(function(){ $('.agency-plans').fadeIn();}, 500);
      $('.tab-nav a').removeClass('active');
      $(this).addClass('active'); 
    }
  });


  $( ".subscription-type" ).click(function() {

      var disableclass='n';         
      if($(this).hasClass('active')){
      disableclass='y';
    } 
    $('input#plan-selection').val($(this).data('plan'));
    $('.subscription-type').removeClass('active');
    $('.button-planselector').text('Select');

    if(disableclass == 'y'){ 
      $('.active .button-planselector').text('Select');
      $('input#plan-selection').val('');
    }else{
      $(this).addClass('active');
      $('.active .button-planselector').text('Selected');
    }


  });


  /* QUANTITY FUNCTIONS FOR STEP 3 */

  $( ".qty-plus" ).click(function() { 
      var target="#"+$(this).data('qty');
      var oldvalue = $(target).val();
      var newvalue = parseFloat($(target).val()) + 1;
      $(target).val(newvalue);  
  });
  $( ".qty-minus" ).click(function() { 
      var target="#"+$(this).data('qty');
      var oldvalue = $(target).val();
      if (oldvalue > 0) {
        var newVal = parseFloat(oldvalue) - 1;
      } else {
        newVal = 0;
      }
      $(target).val(newVal);  
  });


  /* CHECKOUT REMOVE */

  $( ".remove" ).click(function() { 
      var removeid = "#"+ $(this).data('remove');
      $(removeid).remove();
  });





  $('#checkoutform').on('invalid.fndtn.abide', function () {
    $('html, body').animate({
      scrollTop: $('#checkoutdata').offset().top + 100
    }, 600);
  }).on('valid.fndtn.abide', function () { });
};

$( window ).resize(function() {
  setSizes();
});

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
