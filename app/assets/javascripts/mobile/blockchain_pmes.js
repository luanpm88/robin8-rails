$(document).ready(function() {
  var URLHOST = $('#host_url').val();
  console.log(URLHOST);

  if ($('body').attr('id') === 'wechat_pages_pmes_demo') {
    if ($('#e_wallet_account').val() == '') {
      $('#pmes_reg_page').show();
      $('#pmes_statistics_page').hide();
      $('#pmes_login_page').hide();

      var form_data = {};
      var phone_data = '';
      var device_id_data = '';
      var email_data = '';

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

      // 创建帐号
      $('#pmes_reg_submit_btn').click(function(event) {
        var current_date = new Date();
        current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
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

        var pmes_ctrl = new PMESCtrl(password, email, phone, device_id);
        console.log(pmes_ctrl);
        pmes_ctrl.sign();

        // createAlert('public_key:'+pmes_ctrl.public_key);

        var post_data = {
          'public_key': pmes_ctrl.public_key,
          'message': {
            'email': email, // Robin8用户电子邮件
            'phone': phone, // Robin8用户电话
            'device_id': device_id, // Robin8用户device_id
            'timestamp': current_date // 当前时间 201808091319, 格式 YYYYMMDDHHmm
          },
          'signature': pmes_ctrl.signature
        }
        post_data = JSON.stringify(post_data);
        console.log(post_data);

        // createAlert('post_data:'+post_data);

        // createAlert('domain:'+URLHOST);

        var mnemonic_tips = '<p>请记住您的 Mnemonic</p><p>'+ pmes_ctrl.mnemonic +'</p>';
        createConfirm(
          mnemonic_tips,
          {
            title: ' ',
            confirm: '已记下',
            cancel: '取消'
          },
          function(type) {
            if (type == 'confirm') {
              $.ajax({
                url: 'https://pmes.robin8.io/api/accounts/',
                type: 'POST',
                data: post_data,
                success: function(data) {
                  console.log(data);
                  console.log(JSON.parse(data.wallets));

                  var post_native_data = {
                    token: pmes_ctrl.token,
                    public_key: pmes_ctrl.public_key
                  };
                  console.log(post_native_data);

                  post_native_data = JSON.stringify(post_native_data);
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
                    url: URLHOST + '/pages/bind_e_wallet',
                    type: 'POST',
                    data: {
                      put_address: put_puttest.address
                    },
                    beforeSend: function(xhr) {
                      xhr.setRequestHeader('Authorization', current_token);
                    },
                    success: function(data) {
                      // createAlert(data);
                      // location.reload();

                      $('#amount_active').html(put_puttest.amount_active);
                      $('#amount_frozen').html(put_puttest.amount_frozen);
                      $('#pmes_reg_page').hide();
                      $('#pmes_statistics_page').show();
                      // $('#pmes_login_page').show();
                    },
                    error: function(xhr, type) {
                      createAlert('ruby error');
                      console.log('error');
                    }
                  });
                },
                error: function(xhr, type) {
                  createAlert('pmes post error');
                  console.log('error');
                }
              });
            }
          }
        );
      });
    } else {
      $('#pmes_reg_page').hide();
      $('#pmes_login_page').show();
    }

    // 已有帐号
    $('#login_password').pwd('init');

    // var $pw_container = $('#password_input_container');
    // var $pw_item = $pw_container.find('.password-input-item');
    // var pw_container_width = $pw_container.outerWidth();

    // $pw_item.each(function(index, el) {
    //   var $item = $(el);
    //   $item.css({
    //     width: (pw_container_width - 7) / 6,
    //     height: (pw_container_width - 7) / 6,
    //     lineHeight: (pw_container_width - 7) / 6 + 'px'
    //   });

    //   $item.click(function(event) {
    //     $('#login_password').focus();
    //   });
    // });

    // $('#login_password').on('keyup change', function(event) {
    //   var _val = $(this).val();
    //   $pw_item.html('');
    //   for (var i = _val.length - 1; i >= 0; i--) {
    //     $pw_item.eq(i).html(_val[i]);
    //   }
    // });

    $('#pmes_login_btn').click(function(event) {
      var current_date = new Date();
      current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
      var login_password = $('#login_password').val();
      if (login_password == '') {
        createAlert('请输入密码');
        return false;
      }

      var get_native_data = {
        token: '',
        public_key: ''
      };

      if (typeof jwPut != 'undefined' && jwPut.put_pmes_data() != '') {
        get_native_data = JSON.parse(jwPut.put_pmes_data());
      }

      var post_token = get_native_data.token.toString();
      var post_public_key = get_native_data.public_key.toString();

      // createAlert(get_native_data.token);
      // createAlert(get_native_data.public_key);

      var pmes_sign = PMES.sign(
        post_token,
        {
          'message': {
            'timestamp': current_date // 当前201808091319, 格式 YYYYMMDDHHmm
          }
        },
        login_password
      );

      var post_data = {
        'public_key': post_public_key,
        'message': {
          'timestamp': current_date // 当前时间 201808091319, 格式 YYYYMMDDHHmm
        },
        'signature': pmes_sign.signature
      };
      // post_data = JSON.stringify(post_data);
      // createAlert(post_public_key);

      $.ajax({
        url: 'https://pmes.robin8.io/api/accounts/'+ post_public_key +'/',
        type: 'GET',
        success: function(data) {
          console.log(data);
          console.log(JSON.parse(data.wallets));
          var wallets_data = JSON.parse(data.wallets);
          var put_puttest = '';
          $.each(wallets_data, function(index, el) {
            if (el.coinid === 'PUTTEST') {
              put_puttest = el;
            }
          });
          $('#amount_active').html(put_puttest.amount_active);
          $('#amount_frozen').html(put_puttest.amount_frozen);

          $('#pmes_login_page').hide();
          $('#pmes_statistics_page').show();
        },
        error: function(xhr, type) {
          createAlert(xhr);
          createAlert(type);
          console.log('error');
        }
      });
    });

  }
});

function dataFromNative(demo_data) {
  createAlert(demo_data);
}

function PMESCtrl(password, email, phone, device_id) {
  this.password = password;
  this.email = email;
  this.phone = phone;
  this.device_id = device_id;

  this.create = PMES.create(this.password);
  this.token = this.create.token;
  this.public_key = this.create.public_key;
  this.mnemonic = this.create.mnemonic;
  this.signature = '';
}

PMESCtrl.prototype = {
  constructor: PMESCtrl,
  sign: function() {
    var current_date = new Date();
    current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
    var that = this;
    var pmes_sign = PMES.sign(
      that.token,
      {
        'message': {
          'email': that.email, // Robin8用户电子邮件
          'phone': that.phone, // Robin8用户电话
          'device_id': that.device_id, // Robin8用户device_id
          'timestamp': current_date // 当前201808091319, 格式 YYYYMMDDHHmm
        }
      },
      that.password
    );
    that.signature = pmes_sign.signature;
  }
}
