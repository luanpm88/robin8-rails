//= require assets
//= require jquery
//= require jquery_ujs
//= require bootstrap

show_sign_up_modal = function() {
  if($('.quick-login').attr("show-after-loading") == 'true'){
    $("#signinupModal").modal('show');
  }

  $(".mobile-number").val("").attr("placeholder", "手机号码/邮箱");
  $(".verify_code").val("").attr("placeholder", "输入验证码");
  $(".password").val("").attr("placeholder", "设置密码");
  $(".new-password").val("").attr("placeholder", "设置新密码");

  // 验证user是否登录过网站，如果登录过，则选择登录 tab
  $.ajax({
    method: 'GET',
    url: '/pages/check_used_to_signed_in',
  })
  .done(function(data){
    if (data['success']) {
      $('.sign-in-tab').click();
    }
  });
}

$(function(){

  if($("#downloadModal").attr("show-after-loading") == 'true'){
    $("#downloadModal").modal('show');
  }

  setTimeout(show_sign_up_modal,500)

  $('.quick-login').click(function() {
    // 清除不必要的填充
    $(".mobile-number").val("").attr("placeholder", "手机号码/邮箱");
    $(".verify_code").val("").attr("placeholder", "输入验证码");
    $(".password").val("").attr("placeholder", "设置密码");
    $(".new-password").val("").attr("placeholder", "设置新密码");

    // 验证user是否登录过网站，如果登录过，则选择登录 tab
    $.ajax({
      method: 'GET',
      url: '/pages/check_used_to_signed_in',
    })
    .done(function(data){
      if (data['success']) {
        $('.sign-in-tab').click();
      }
    });
  });

  $(".rucaptcha_tag").click(function(){
    $.ajax({
      method: "GET",
      url: "/rucaptcha/"
    }).done(function(data){
      new_src = $(".rucaptcha_tag").attr('src').split('?')[0] + '?' + (new Date()).getTime()
      $(".rucaptcha_tag").attr("src", new_src)
    })
  });

  $('.send_verify_code').click(function(){
    var phone_number = $('.brand_mobile_number').val().trim();

    if(phone_number.match(/^1[34578][0-9]{9}$/)) {
      console.log('good mobile')
      $(".tips .phone-number-error").hide();
      $('.bs-example-modal-sm').modal()
    } else {
      $(".tips p").hide();
      $(".tips .phone-number-error").show();
    }
  });

  $('.send-forget-password-verify-code').click(function(){
    var phone_number = $('.forget-password-brand-mobile-number').val().trim();
    if(phone_number.match(/^1[34578][0-9]{9}$/)) {
      console.log('good mobile')

      $.ajax({
        method: 'GET',
        url: '/users/check_exist_by_mobile_number',
        beforeSend: function(xhr){
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        data: {'phone_number': phone_number}
      })
      .done(function(data){
        if (data['no_user']) {
          $(".tips p").hide();
          $(".tips .no-phone-number").show();
        } else {
          $(".tips .phone-number-error").hide();
          $('.forget-password-rucaptcha-modal-sm').modal()
        }
      });

    } else {
      $(".tips p").hide();
      $(".tips .phone-number-error").show();
    }
  });


  $('.rucaptcha_ok').click(function(){
    // send code and mobile number to request send sms
    var rucaptcha_code = $('.rucaptcha_input').val().trim();
    var phone_number = $('.brand_mobile_number').val().trim();
    var send_verify_code_text = $('.send_verify_code').text();
    var count = 60;
    var countdown;

    console.log('phone_number', phone_number);

    $.ajax({
      method: 'POST',
      url: '/kols/send_sms',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      data: {'phone_number': phone_number, 'role': 'user', '_rucaptcha': $('.rucaptcha_input').val()}
    })
    .done(function(data){
      $('.bs-example-modal-sm .tips').children().hide();

      if (data['mobile_number_is_blank']) {
        alert('mobile number is blank');
        $('.rucaptcha_error')
      } else if (data['not_unique']) {
        $(".brand_mobile_number").css({"border-color": "red"})
        $(".not_unique_number").show();
        $(".not_unique_number").siblings().hide();
      } else if (data['rucaptcha_not_right']) {
        $(".rucaptcha_not_right").show();
      } else if (data['code']) {
        $(".brand_mobile_number").css({"border-color": "red"})
        $(".send_sms_failed").show();
        $(".send_sms_failed").siblings().hide();
      } else {
        countdown = setInterval(CountDown, 1000);
        $(".send_sms_success").show();
        $(".send_sms_success").siblings().hide();
        $('.bs-example-modal-sm').modal('hide');
      }
    });

    function CountDown(){
      $('.send_verify_code').attr('disabled', 'true');
      $('.send_verify_code').text(count + ' s');
      if (count===0){
        $('.send_verify_code').text(send_verify_code_text).removeAttr('disabled');
        clearInterval(countdown);
      }
      count--;
    }

  });

  $('.forget-password-rucaptcha-ok').click(function(){
    // send code and mobile number to request send sms
    var rucaptcha_code = $('.forget-password-rucaptcha-input').val().trim();
    var phone_number = $('.forget-password-brand-mobile-number').val().trim();
    var send_verify_code_text = $('.send-forget-password-verify-code').text();
    var count = 60;
    var countdown;

    console.log('phone_number', phone_number);

    $.ajax({
      method: 'POST',
      url: '/kols/send_sms',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      data: {'phone_number': phone_number, 'role': 'user', 'forget_password': true, '_rucaptcha': $('.forget-password-rucaptcha-input').val()}
    })
    .done(function(data){
      $('.forget-password-rucaptcha-modal-sm .tips').children().hide();

      if (data['mobile_number_is_blank']) {
        alert('mobile number is blank');
        $('.rucaptcha_error')
      } else if (data['no_user']) {
        $(".brand_mobile_number").css({"border-color": "red"})
        $(".no_user").show();
        $(".no_user").siblings().hide();
      } else if (data['rucaptcha_not_right']) {
        $(".rucaptcha_not_right").show();
      } else if (data['code']) {
        $(".brand_mobile_number").css({"border-color": "red"})
        $(".send_sms_failed").show();
        $(".send_sms_failed").siblings().hide();
      } else {
        countdown = setInterval(CountDown, 1000);
        $(".send_sms_success").show();
        $(".send_sms_success").siblings().hide();
        $('.forget-password-rucaptcha-modal-sm').modal('hide');
      }
    });

    function CountDown(){
      $('.send-forget-password-verify-code').attr('disabled', 'true');
      $('.send-forget-password-verify-code').text(count + ' s');
      if (count===0){
        $('.send-forget-password-verify-code').text(send_verify_code_text).removeAttr('disabled');
        clearInterval(countdown);
      }
      count--;
    }

  });

  $('.forget-password-btn').click(function() {
    $('#signinupModal').modal('hide');
    $('#forget-password-modal').modal('show');
  })

})
