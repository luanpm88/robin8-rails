//= require website/vendor/jquery
//= require website/foundation/foundation
//= require website/foundation/foundation.abide
//= require website/foundation/foundation.alert
//= require website/foundation/foundation.clearing
//= require website/foundation/foundation.dropdown
//= require website/foundation/foundation.equalizer
//= require website/foundation/foundation.interchange
//= require website/foundation/foundation.magellan
//= require website/foundation/foundation.reveal
//= require website/foundation/foundation.tab
//= require website/foundation/foundation.tooltip
//= require website/foundation/foundation.topbar
//= require website/vendor/fastclick
//= require website/vendor/jquery.cookie
//= require website/vendor/jquery-ui
//= require website/vendor/modernizr
//= require website/vendor/placeholder
//= require website/app
//= require website/foundation.min
//= require select2

$(function(){
  $(".send_sms").click(function(){
    var $phone_number = $("#kol_mobile_number").val();
    $.ajax({
      method: "POST",
      url: "/kols/send_sms",
      data: {"phone_number": $phone_number}
    });
  });
});
