$(document).ready(function() {
  if ($('body').attr('id') === 'mobile_pages_vote_share') {
    var kol_id = $('#kol_id').val();

    $('#voter_code_btn').click(function(event) {
      var $btn = $(this);
      var phone = $.trim($('#voter_phone').val());

      if (phone === '') {
        alert('请输入您的手机号码！');
        return false;
      } else if (phone != '' && !verify_phone.test(phone)) {
        alert('请输入正确的手机号码！');
        return false;
      }

      $.ajax({
        url: '/api/v2_1/kols/vote_sms',
        type: 'GET',
        data: {
          mobile_number: phone,
          kol_id: kol_id
        },
        success: function(data) {
          console.log(data);
          if (data.error == 1) {
            alert(data.detail);
            return false;
          }
          countdownCode($btn);
        },
        error: function(xhr, type) {
          console.log(xhr);
          console.log(type);
        }
      });

    });

    $('#voter_submit_btn').click(function(event) {
      var phone = $.trim($('#voter_phone').val());
      var voter_code = $.trim($('#voter_code').val());

      if (phone === '') {
        alert('请输入您的手机号码！');
        return false;
      } else if (phone != '' && !verify_phone.test(phone)) {
        alert('请输入正确的手机号码！');
        return false;
      }
      if (voter_code === '') {
        alert('请输入手机验证码！');
        return false;
      }

      $.ajax({
        url: '/api/v2_1/kols/vote_sms',
        type: 'POST',
        data: {
          mobile_number: phone,
          kol_id: kol_id,
          code: voter_code
        },
        success: function(data) {
          console.log(data);
          if (data.error == 1) {
            alert(data.detail);
            return false;
          }
          $('#new_user_panel').fadeOut();
          $('#liked_success_panel').fadeIn();
        },
        error: function(xhr, type) {
          console.log(xhr);
          console.log(type);
        }
      });

    });
  }
});
