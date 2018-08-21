$(document).ready(function() {
  if ($('body').attr('id') === 'wechat_pages_pmes_demo') {
    var URLHOST = window.location.host;
    var form_data = {};
    var phone_data = '';
    var device_id_data = '';
    var email_data = '';

    var current_date = new Date();
    current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
    console.log('当前时间:'+ current_date);

    if (typeof jwPut != 'undefined' && jwPut.put_ToJs() != '') {
      form_data = JSON.parse(jwPut.put_ToJs());
      phone_data = form_data.phone_num;
      device_id_data = form_data.device_id;
      email_data = form_data.email;
    }

    // createAlert(form_data);
    // createAlert(form_data.phone_num);
    // createAlert(form_data.device_id);
    // createAlert(form_data.email);

    $('#email').val(email_data);
    $('#phone').val(phone_data);
    $('#device_id').val(device_id_data);

    var email = $('#email').val();
    var phone = $('#phone').val();
    var device_id = $('#device_id').val();
    var current_token = $('#current_token').val();

    $('#pmes_reg_submit_btn').click(function(event) {
      var password = $('#password').val();
      var password_confirm = $('#password_confirm').val();
      if (password == '') {
        createAlert('请输入密码');
        return false;
      }
      if (password_confirm == '') {
        createAlert('请确认密码');
        return false;
      }
      if (password != password_confirm) {
        createAlert('两次密码输入不一致');
        return false;
      }

      var pmes_create = PMES.create(password);
      console.log('create:', pmes_create);

      var post_data = {
        'message': {
          'email': email, //Robin8用户电子邮件
          'phone': phone, //Robin8用户电话
          'timestamp': current_date // 現在時間 201808091319, 格式 YYYYMMDDHHmm
        }
      };

      var pmes_create = PMES.sign(
        pmes_create.token,
        post_data,
        password
      );
      post_data.public_key = pmes_create.public_key;
      post_data.signature = pmes_sign.signature;

      console.log('public_key', pmes_create.public_key);
      console.log('signature:', pmes_create.signature);

      post_data = JSON.stringify(post_data);

      $.ajax({
        url: 'http://190.2.149.83/api/accounts/',
        type: 'POST',
        data: post_data,
        success: function(data) {
          console.log(data);
          console.log(JSON.parse(data.wallets));

          var post_native_data = JSON.stringify(data);
          console.log(post_native_data);

          if (typeof jwPut != 'undefined') {
            jwPut.put_Login(post_native_data);
          }

          var wallets_data = JSON.parse(data.wallets);
          var put_puttest = '';
          $.each(wallets_data, function(index, el) {
            if (el.coinid === 'PUTTEST') {
              put_puttest = el;
            }
          });

          console.log(put_puttest.address);

          $('#pmes_reg_page').hide();
          $('#pmes_statistics_page').removeClass('hide');

        //   $.ajax({
        //     url: URLHOST + '/api/v2_0/kols/bind_e_wallet',
        //     type: 'POST',
        //     data: {
        //       'put_address': put_puttest.address
        //     },
        //     beforeSend: function(xhr) {
        //       xhr.setRequestHeader('Authorization', current_token);
        //     },
        //     success: function(data) {
        //       createAlert(data);
        //     },
        //     error: function(xhr, type) {
        //       console.log('error');
        //     }
        //   });
        },
        error: function(xhr, type) {
          console.log('error');
        }
      });
    });
  }
});

function dataFromNative(demo_data) {
  createAlert(demo_data);
}
