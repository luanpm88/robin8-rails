$(document).ready(function() {
  var current_admin_user_id = $('#current_admin_user_id').val();

  if ($('body').attr('id') === 'admin_campaigns_index') {
    // 创建帐号
    $('#pmes_reg_submit_btn').click(function(event) {
      var current_date = new Date();
      current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
      var email = $('#email').val();
      var password = $('#password').val();
      var password_confirm = $('#password_confirm').val();

      if (password == '') {
        alert('请输入密码');
        return false;
      } else if (password != '' && !verify_pw.test(password)) {
        alert('请输入6位数字作为密码');
        return false;
      }
      if (password_confirm == '') {
        alert('请确认密码');
        return false;
      }
      if (password != password_confirm) {
        alert('两次密码输入不一致');
        return false;
      }

      var pmes_ctrl = new PMESCtrl(password, email);
      console.log(pmes_ctrl);
      pmes_ctrl.sign();
      if (pmes_ctrl.error_tips === 'invaild token or password') {
        alert('系统错误，请稍候');
        return false;
      }

      var post_data = {
        'public_key': pmes_ctrl.public_key,
        'message': {
          'email': email, // Robin8用户电子邮件
          'phone': '', // Robin8用户电话
          'device_id': '', // Robin8用户device_id
          'timestamp': current_date // 当前时间 201808091319, 格式 YYYYMMDDHHmm
        },
        'signature': pmes_ctrl.signature
      }
      post_data = JSON.stringify(post_data);
      console.log(post_data);

      var pmes_mnemonic = pmes_ctrl.mnemonic;
      var pmes_token = pmes_ctrl.token;
      var mnemonic_tips = '<p>'+ pmes_mnemonic +'</p><br/><p class="text-danger">注意：若不保存，则有账号丢失风险</p>';
      var mnemonic_input = '<textarea class="form-control" rows="4" id="mnemonic_input"></textarea>';

      $('#mnemonic_modal_text').html(mnemonic_tips);
      $('#pmestoken_modal_text').html(pmes_token);
      $('#mnemonic_modal').modal('show');

      $('#mnemonic_text_get').click(function(event) {
        $('#mnemonic_modal').modal('hide');
        $('#mnemonic_input_modal').modal('show');
      });

      $('#mnemonic_confirm').click(function(event) {
        $('#mnemonic_input_modal').modal('hide');
        $('#pmestoken_modal').modal('show');
      });

      $('#pmestoken_text_get').click(function(event) {
        var mnemonic_input_val = $.trim($('#mnemonic_input').val());

        if (mnemonic_input_val === pmes_mnemonic) {
          $.ajax({
            url: URLHOST + '/api/accounts/',
            type: 'POST',
            data: post_data,
            success: function(data) {
              console.log(data);
              console.log(JSON.parse(data.wallets));

              var wallets_data = JSON.parse(data.wallets);
              var put_put = '';
              $.each(wallets_data, function(index, el) {
                if (el.coinid === 'PUT') {
                  put_put = el;
                }
              });

              console.log(put_put.address);

              $.ajax({
                url: SERVERHOST + 'marketing_dashboard/admin_users/'+ current_admin_user_id +'/bind_e_wallet',
                type: 'POST',
                beforeSend: function(xhr) {
                  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
                },
                data: {
                  put_address: put_put.address
                },
                success: function(data) {
                  console.log(data);
                  location.reload();
                },
                error: function(xhr, type) {
                  alert('ruby post error');
                  console.log('error');
                }
              });
            },
            error: function(xhr, type) {
              alert('pmes post error');
              console.log('error');
            }
          });
        } else {
          alert('Mnemonic不正确');
        }
      });

    });
  }

  if ($('body').attr('id') === 'admin_transactions_index') {
    // 批量付款
    $('#put_remit_btn').click(function(event) {
      $('#token_input_modal').modal('show');
    });

    $('#token_confirm').click(function(event) {
      var $put_remit_table = $('#put_remit_table');
      var put_remit_token = $put_remit_table.find('.put-remit-token');
      var password = $('#password_input').val();
      var token = $('#token_input').val();
      var current_date = new Date();
      current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');

      var pmes_sign = PMES.sign(
        token,
        {
          'message': {
            'timestamp': current_date
          }
        },
        password
      );

      console.log(pmes_sign);
      var signature = pmes_sign.signature;

      $.each(put_remit_token, function(index, el) {
        var $item = $(el);
        var put_address = $item.html();
        console.log(put_address);

        var post_data = {
          'public_key': '',
          'message': {
            'timestamp': current_date,
            'coinid': 'PUT',
            'amount': '',
            'address': '',
            'recvWindow': ''
          },
          'signature': signature
        };
        post_data = JSON.stringify(post_data);
        console.log(post_data);

        $.ajax({
          url: URLHOST + '/api/accounts/withdraw/',
          type: 'POST',
          data: post_data,
          success: function(data) {
            console.log(data);
          },
          error: function(xhr, type) {
            console.log('error');
          }
        });
      });
    });
  }
});
