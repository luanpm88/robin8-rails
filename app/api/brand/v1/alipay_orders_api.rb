# encoding: utf-8
module Brand
  module V1
    class AlipayOrdersAPI < Base
      resource :alipay_orders do
        group do
          before do
            authenticate!
          end

          desc 'Create a alipay order'
          params do
            requires :credits, type: Integer
          end
          post do
            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            credits = declared(params)[:credits]
            ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
            @alipay_order =  current_user.alipay_orders.build({trade_no: trade_no, credits: credits})
            if @alipay_order.save
              alipay_recharge_url = Alipay::Service.create_direct_pay_by_user_url(
                                      { out_trade_no: trade_no,
                                        subject: 'Robin8账户充值',
                                        total_fee: credits,
                                        return_url: 'http://robin8-staging.cn/brand',
                                        notify_url: 'http://robin8-staging.cn/brand_api/v1/alipay_orders/alipay_notify'
                                      },
                                      {
                                        sign_type: 'RSA',
                                        key: ALIPAY_RSA_PRIVATE_KEY
                                      }
                                    )
              return { alipay_recharge_url: alipay_recharge_url }
            else
              return error_unprocessable! @alipay_order.errors.messages.first.last.first
            end
          end
        end

        group do
          post '/alipay_notify' do
            params.delete 'route_info'
            if Alipay::Sign.verify?(params) && Alipay::Notify.verify?(params)
              @alipay_order = AlipayOrder.find_by trade_no: params[:out_trade_no]
              if params[:trade_status] == 'TRADE_SUCCESS'
                @alipay_order.pay
                @alipay_order.save_alipay_trade_no(params[:trade_no])
                @alipay_order.save_trade_no_to_transaction(params[:out_trade_no])
              end
              env['api.format'] = :txt
              body "success"
            else
              return error_unprocessable! "充值失败，请重试"
            end
          end
        end
      end
    end
  end
end
