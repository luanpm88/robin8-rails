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
  $(".rucaptcha_tag_box").click(function(){
    $.ajax({
      method: "GET",
      url: "/rucaptcha/"
    }).done(function(data){
      new_src = $(".rucaptcha_tag").attr('src').split('?')[0] + '?' + (new Date()).getTime()
      $(".rucaptcha_tag").attr("src", new_src)
    })
  });

  $(".send_sms").click(function(){
    var phone_number = $("#kol_mobile_number").val().trim();
    var old_button_text = $(".send_sms").text();
    var count = 60;
    var countdown;

    function CountDown(){
      $(".send_sms").attr('disabled', 'true');
      $(".send_sms").text(count + " s");
      if (count === 0){
        $(".send_sms").text(old_button_text).removeAttr('disabled');
        clearInterval(countdown);
      }
      count--;
    }

    if (phone_number.match(/^1[34578][0-9]{9}$/) || phone_number == "robin8.best"){
      $.ajax({
        method: "POST",
        url: "/kols/send_sms",
          beforeSend: function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
          },
         data: {"phone_number": phone_number, 'role': $("#kol_mobile_number").attr("data-role"), '_rucaptcha':  $(".rucaptcha_input").val()}
      })
        .done(function(data) {
          $(".tips").children().hide();
          if (data["mobile_number_is_blank"]) {
            $("#kol_mobile_number").focus().blur();
            return null;
          }


          if (data["not_unique"]) {
            $("#kol_mobile_number").css({"border-color": "red"})
            $(".not_unique_number").show();
            $(".not_unique_number").siblings().hide();
          } else if (data["rucaptcha_not_right"]){
            $(".rucaptcha_not_right").show();
          }
          else {
            if (data["code"]) {
              $("#kol_mobile_number").css({"border-color": "red"})
              $(".send_sms_failed").show();
              $(".send_sms_failed").siblings().hide();
            }
            else {
              countdown = setInterval(CountDown, 1000);
              $(".send_sms_success").show();
              $(".send_sms_success").siblings().hide();
            }
          }

        });
    }
    else {
      $("#kol_mobile_number").focus().blur();
    }
  });
});


$(function(){
  $('#kol_mobile_number').on('input',function(){
    $(".tips").children().hide();
  });
});
