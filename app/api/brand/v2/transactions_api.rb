module Brand
  module V2
    class TransactionsAPI < Base
      include Grape::Kaminari
      
      group do
        before do
          authenticate! unless @options[:path].first == '/alipay_notify'
        end
        resource :transactions do

          desc "create transaction"
          params do
            requires :tender_id, type: Integer
            optional :pay_type, type: String
          end
          post "" do
            tender = Tender.find_by_id params[:tender_id]
            return {error: 1, detail: '数据错误，请确认'} unless tender

            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            tender.trade_no = trade_no
            tender.transactions.build(account: current_user, amount: tender.amount, direct: 'creation', subject: 'creation')

            ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
            return_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand' : "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{tender.creation_id}/kols"
            notify_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand_api/v2/alipay_orders/alipay_notify' : "#{Rails.application.secrets[:domain]}/brand_api/v2/transactions/alipay_notify"

            if tender.save
              alipay_recharge_url = Alipay::Service.create_direct_pay_by_user_url(
                                        { out_trade_no: trade_no,
                                          subject: 'creation 订单支付',
                                          total_fee: (ENV["total_fee"] || tender.amount).to_f,
                                          return_url: return_url,
                                          notify_url: notify_url
                                        },
                                        {
                                          sign_type: 'RSA',
                                          key: ALIPAY_RSA_PRIVATE_KEY
                                        }
                                      )
              return { alipay_recharge_url: alipay_recharge_url, return_url:  return_url, notify_url: notify_url}
            else
              return error_unprocessable! tender.errors.messages
            end
          end

          post '/alipay_notify' do
            params.delete 'route_info'
            if Alipay::Sign.verify?(params) && Alipay::Notify.verify?(params)
              @tender = Tender.find_by trade_no: params[:out_trade_no]
              if params[:trade_status] == 'TRADE_SUCCESS'
                @tender.update_attributes!(trade_no: params[:out_trade_no], status: 'paid')
                @tender.transactions.order("created_at desc").first.update_attributes!(trade_no: params[:out_trade_no])
              end
              env['api.format'] = :txt
              body "success"
            else
              return error_unprocessable! "订单支付失败，请重试"
            end
          end


          paginate per_page: 8
          get "/" do
            transactions = paginate(Kaminari.paginate_array(current_user.paid_transactions.includes(:item).order('created_at DESC')))
            present transactions
          end

        end
      end
    end
  end
end