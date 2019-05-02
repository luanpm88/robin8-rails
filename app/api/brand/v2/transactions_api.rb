module Brand
  module V2
    class TransactionsAPI < Base
      include Grape::Kaminari
      
      group do
        before do
          puts @options[:path]
          authenticate! unless @options[:path].first == '/alipay_notify' || @options[:path].first == '/onepay_notify/:onepay_type'
        end
        resource :transactions do

          desc "create transaction"
          params do
            requires :tender_id, type: Integer
            optional :pay_type, type: String
          end
          post "" do
            tender = Tender.find_by_id params[:tender_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found')} unless tender

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
              return {error: 1, detail: tender.errors.messages }
            end
          end
          
          post "onepay" do
            tender = Tender.find_by_id params[:tender_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found')} unless tender

            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            tender.trade_no = trade_no
            tender.transactions.build(account: current_user, amount: tender.amount, direct: 'creation', subject: 'creation')

            secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]
            return_url = "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{tender.creation_id}/kols"
            notify_url = "#{Rails.application.secrets[:domain]}/brand_api/v2/transactions/onepay_notify/" + params[:onepay_type]

            if tender.save
              
              amount = (ENV["total_fee"] || tender.amount).to_f
              amount = (amount * 100).to_i
              
              onepay_recharge_url = OnepayApi.get_direct_pay_url(
                secret,
                {
                  type: params[:onepay_type],
                  amount: amount.to_s,
                  ref: trade_no,
                  info: trade_no,
                  return_url: notify_url,
                  ip: env['REMOTE_ADDR']
                }
              )
              return { onepay_recharge_url: onepay_recharge_url, return_url:  return_url, notify_url: notify_url}
            else
              return {error: 1, detail: tender.errors.messages }
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
              return {error: 1, detail: I18n.t('brand_api.errors.messages.order_pay_failed')}
            end
          end
          
          get '/onepay_notify/:onepay_type' do
            params.delete 'route_info'
            
            secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]
            request_valid = OnepayApi.check_valid_request(secret, params)
            
            puts params[:vpc_TxnResponseCode]
            
            if request_valid && params[:vpc_TxnResponseCode] == '0'
              @tender = Tender.find_by trade_no: params[:vpc_MerchTxnRef]
              if true
                @tender.update_attributes!(trade_no: params[:vpc_MerchTxnRef], status: 'paid')
                @tender.transactions.order("created_at desc").first.update_attributes!(trade_no: params[:vpc_MerchTxnRef])
              end
              env['api.format'] = :txt
              
              
              return_url = "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{@tender.creation_id}/kols"
              body "<script>window.location='#{return_url}'</script>"
            else
              sErrors = {
                "0": "Transaction was successful",
                "?": "Transaction status was unknown",
                "1": "Bank system reject",
                "2": "Bank Declined Transaction",
                "3": "No Reply from Bank",
                "4": "Expired Card",
                "5": "Insufficient funds",
                "6": "Error Communicating with Bank",
                "7": "Payment Server System Error",
                "8": "Transaction Type Not Supported",
                "9": "Bank declined transaction (Do not contact Bank)",
                "A": "Transaction Aborted",
                "B": "Transaction was failed. It cannot authenticated by 3D-Secure Program. Please contact the Issuer Bank for support.",
                "C": "Transaction Cancelled",
                "D": "Deferred transaction has been received and is awaiting processing",
                "F": "Transaction was failed. 3D-Secure authentication was failed.",
                "I": "Card Security Code verification was failed.",
                "L": "Shopping Transaction Locked (Please try the transaction again later)",
                "N": "Cardholder is not enrolled in Authentication scheme",
                "P": "Transaction has been received by the Payment Adaptor and is being processed",
                "R": "Transaction was not processed - Reached limit of retry attempts allowed",
                "S": "Duplicate SessionID (OrderInfo)",
                "T": "Address Verification Failed",
                "U": "Card Security Code Failed",
                "V": "Address Verification and Card Security Code Failed",
                "99": "User Cancel",
              }
  
              error = sErrors[params[:vpc_TxnResponseCode].to_sym].present? ? sErrors[params[:vpc_TxnResponseCode].to_sym] : 'Unknow error!'
              return {error: 1, detail: error }
            end
          end


          
          get "/" do
            transactions = paginate(Kaminari.paginate_array(current_user.paid_transactions.includes(:item).order('created_at DESC')))

            present transactions, with: Entities::Transaction
          end

        end
      end
    end
  end
end