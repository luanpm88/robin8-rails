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
          post do
            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            credits = params[:credits].to_f
            return error_unprocessable! "充值最低金额为#{MySettings.recharge_min_budget}" if MySettings.recharge_min_budget > credits

            invite_code = params[:invite_code]
            ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
            return_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand' : "#{Rails.application.secrets[:domain]}/brand"
            notify_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand_api/v1/alipay_orders/alipay_notify' : "#{Rails.application.secrets[:domain]}/brand_api/v1/alipay_orders/alipay_notify"

            # 账户充值页面 (/brand/financial/recharge) 不再提供开具发票选项，
            # 所以 need_invoice 为 false，tax 为零
            @alipay_order =  current_user.alipay_orders.build({trade_no: trade_no, credits: credits, tax: 0, need_invoice: false, invite_code: invite_code})
            if @alipay_order.save
              alipay_recharge_url = Alipay::Service.create_direct_pay_by_user_url(
                                      { out_trade_no: trade_no,
                                        subject: 'Robin8账户充值',
                                        total_fee: (ENV["total_fee"] || credits).to_f,
                                        return_url: return_url,
                                        notify_url: notify_url
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
                @alipay_order.with_lock do
                  @alipay_order.pay
                  @alipay_order.save_tax_to_transaction
                end
              end
              @alipay_order.save_alipay_trade_no(params[:trade_no])
              @alipay_order.save_trade_no_to_transaction(params[:out_trade_no])
              # 送积分{_method, score, owner, resource, expired_at, remark}
              if pr = Promotion.valid && pr.min_credit < @alipay_order.credits
                Credit.gen_record(
                  'recharge',
                  (@alipay_order.credits * pr.rate).to_i,
                  @alipay_order.user,
                  @alipay_order,
                  pr.valid_days_count.days.since,
                  "充#{@alipay_order.credits}元, 赠送#{(@alipay_order.credits * pr.rate).to_i}积分"
                )
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
