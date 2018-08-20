$(document).ready(function() {
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

  // alert(form_data);
  // alert(form_data.phone_num);
  // alert(form_data.device_id);
  // alert(form_data.email);

  $('#email').val(email_data);
  $('#phone').val(phone_data);
  $('#device_id').val(device_id_data);

  var email = $('#email').val();
  var phone = $('#phone').val();
  var device_id = $('#device_id').val();
  var password = $('#password').val();
  var current_token = $('#current_token').val();

  var pems_create = PMES.create('test_password');
  console.log('create:', pems_create);

  var pems_sign = PMES.sign(
    pems_create.token,
    {
      'message': {
        'timestamp': current_date,
        'coinid': 'PUTTEST',
        'amount': '100000000000',
        'address': 'qZZfBCVXLHBt6ou1ZoZW6LiZH1qDHbWq8i',
        'recvWindow': 5000
      }
    },
    'test_password'
  );

  console.log('signature:', pems_sign.signature);

  var post_data = {
    'public_key': pems_create.public_key, //公開钥匙
    'message': {
      'email': email, //Robin8用户电子邮件
      'phone': phone, //Robin8用户电话
      'timestamp': current_date // 現在時間 201808091319, 格式 YYYYMMDDHHmm
    },
    'signature': pems_sign.signature
  };

  post_data = JSON.stringify(post_data);
  console.log(pems_create.public_key);

  $('#pmes_reg_submit_btn').click(function(event) {
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

        $.ajax({
          url: URLHOST + '/api/v2_0/kols/bind_e_wallet',
          type: 'POST',
          data: {
            'put_address': put_puttest.address
          },
          beforeSend: function(xhr) {
            xhr.setRequestHeader('Authorization', current_token);
          },
          success: function(data) {
            alert(data);
          },
          error: function(xhr, type) {
            console.log('error');
          }
        });
      },
      error: function(xhr, type) {
        console.log('error');
      }
    });
  });
});

function dataFromNative(demo_data) {
  alert(demo_data);
}
