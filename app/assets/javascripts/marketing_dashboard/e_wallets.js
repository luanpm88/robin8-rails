$(document).ready(function() {
  if ($('body').attr('id') === 'admin_campaigns_index') {
    var current_admin_user_id = $('#current_admin_user_id').val();

    $('#put_create_btn').click(function(event) {
      $('#put_create_modal').modal('show');
    });

    // 创建帐号
    $('#pmes_reg_submit_btn').click(function(event) {
      var current_date = new Date();
      current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
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

      var pmes_ctrl = new PMESCtrl(password);
      console.log(pmes_ctrl);
      pmes_ctrl.sign();
      if (pmes_ctrl.error_tips === 'invaild token or password') {
        alert('系统错误，请稍候');
        return false;
      }

      var post_data = {
        'public_key': pmes_ctrl.public_key,
        'message': {
          'email': '', // Robin8用户电子邮件
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

      $('#put_create_modal').modal('hide');
      $('#mnemonic_modal').modal('show');

      $('#mnemonic_text_get').click(function(event) {
        $(this).attr('disabled', true);
        $('#mnemonic_modal').modal('hide');
        $('#mnemonic_input_modal').modal('show');
      });
      $('#mnemonic_modal').on('hidden.bs.modal', function (e) {
        $('#mnemonic_text_get').attr('disabled', false);
      });

      $('#mnemonic_confirm').click(function(event) {
        $(this).attr('disabled', true);
        $('#mnemonic_input_modal').modal('hide');
        $('#pmestoken_modal').modal('show');
      });
      $('#mnemonic_input_modal').on('hidden.bs.modal', function (e) {
        $('#mnemonic_confirm').attr('disabled', false);
      });

      $('#pmestoken_text_get').click(function(event) {
        var mnemonic_input_val = $.trim($('#mnemonic_input').val());
        var $btn = $(this);

        if (mnemonic_input_val === pmes_mnemonic) {
          $btn.attr('disabled', true);
          $.ajax({
            url: URLHOST + '/api/accounts/',
            type: 'POST',
            data: post_data,
            success: function(data) {
              console.log(data);
              console.log(JSON.parse(data.wallets));
              alert('创建成功！');
              $('#pmestoken_modal').modal('hide');
              $('#pmestoken_modal').on('hidden.bs.modal', function (e) {
                $btn.attr('disabled', false);
              });
              // var wallets_data = JSON.parse(data.wallets);
              // var put_put = '';
              // $.each(wallets_data, function(index, el) {
              //   if (el.coinid === 'PUT') {
              //     put_put = el;
              //   }
              // });

              // console.log(put_put.address);
            },
            error: function(xhr, type) {
              alert('pmes post error');
              $btn.attr('disabled', false);
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
    var btn_type = '';
    var campaign_id = $('#campaign_id').val();
    // 批量付款
    $('#put_remit_btn').click(function(event) {
      btn_type = 'pay';
      $('#token_input_modal').modal('show');
    });

    // 钱包详情
    $('#wallet_detail_btn').click(function(event) {
      btn_type = 'wallet';
      $('#token_input_modal').modal('show');
    });

    $('#token_confirm').click(function(event) {
      var $btn = $(this);
      var password = $.trim($('#password_input').val());
      var token = $.trim($('#token_input').val());
      var current_date = new Date();
      current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');

      if (password == '') {
        alert('请输入密码');
        return false;
      }
      if (token == '') {
        alert('请输入token');
        return false;
      }

      // verify token and password
      var pmes_sign = PMES.sign(
        token,
        {
          'message': {
            'timestamp': current_date
          }
        },
        password
      );
      if (Object.keys(pmes_sign).indexOf('error') > -1) {
        alert('密码错误，请重新输入');
        return false;
      }

      console.log(pmes_sign);
      $btn.attr('disabled', true);
      if (btn_type === 'pay') {
        console.log('批量付款');
        var $put_remit_table = $('#put_remit_table');
        var $table_tr = $put_remit_table.find('tr');

        $.each($table_tr, function(index, el) {
          var $item = $(el);
          var put_address = $item.find('.put-remit-token').html();
          var put_amount = parseFloat($item.find('.put-remit-amount').html());
          var put_tr_id = $item.find('.put-tr-id').html();
          var put_tx_id = '';
          var $put_tx_id = $item.find('.put-tx-id');
          console.log(put_address);
          console.log(put_amount);
          var cur_date = new Date();
          cur_date = cur_date.customFormat('#YYYY##MM##DD##hhh##mm#');
          var post_data = {};

          var post_data_message = {
            'timestamp': cur_date,
            'coinid': 'PUT',
            'amount': put_amount,
            'address': put_address,
            'recvWindow': 5000
          };

          var signed = PMES.sign(token, post_data_message, password);
          post_data.message = post_data_message;
          post_data.signature = signed.signature;
          post_data.public_key = signed.public_key;

          post_data = JSON.stringify(post_data);
          console.log(post_data);

          $.ajax({
            url: URLHOST + '/api/accounts/withdraw/',
            type: 'POST',
            data: post_data,
            success: function(data) {
              console.log(data);
              $('#token_input_modal').modal('hide');
              $('#token_input_modal').on('hidden.bs.modal', function (e) {
                $btn.attr('disabled', false);
              });

            //   $.ajax({
            //     url: SERVERHOST + '/marketing_dashboard/e_wallets/campaigns/'+ campaign_id +'/transactions/update_txid',
            //     type: 'POST',
            //     data: {
            //       tr_id: put_tr_id,
            //       tx_id: put_tx_id
            //     },
            //     success: function(data) {
            //       console.log(data);
            //       $put_tx_id.html(put_tx_id);
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

      if (btn_type === 'wallet') {
        console.log('钱包详情');
        $.ajax({
          url: URLHOST + '/api/accounts/'+ pmes_sign.public_key +'/',
          type: 'GET',
          success: function(data) {
            if (!!data.wallets) {
              var wallets_data = JSON.parse(data.wallets);
              console.log(wallets_data);
              $.each(wallets_data, function(index, el) {
                $('#wallet_detail_container').append(createWalletTab(el));
              });

              $('#wallet_detail_publickey').html(pmes_sign.public_key);
              $('#token_input_modal').modal('hide');
              $('#token_input_modal').on('hidden.bs.modal', function (e) {
                $btn.attr('disabled', false);
              });
              $('#wallet_detail_modal').modal('show');
            } else {
              alert('没有钱包数据');
            }
          },
          error: function(xhr, type) {
            console.log('error');
          }
        });
      }
    });
  }
});

function createWalletTab(data) {
  var coinid = data.coinid,
      address = data.address,
      amount_active = data.amount_active,
      amount_frozen = data.amount_frozen;

  var _ui = '<table class="table table-striped">' +
              '<thead>' +
                '<tr>' +
                  '<th colspan="2">coinid: '+ coinid +'</th>' +
                '</tr>' +
              '</thead>' +
              '<tbody>' +
                '<tr>' +
                  '<td colspan="2">address: '+ address +'</td>' +
                '</tr>' +
                '<tr>' +
                  '<td>amount_active: '+ amount_active +'</td>' +
                  '<td>amount_frozen: '+ amount_frozen +'</td>' +
                '</tr>' +
              '</tbody>' +
            '</table>';
  return _ui;
}