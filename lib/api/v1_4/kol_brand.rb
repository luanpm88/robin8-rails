module API
  module V1_4
    class KolBrand < Grape::API
      resources :kol_brand do
        before do
          action_name =  @options[:path].join("")
          authenticate! if action_name != '/notify'
        end

        desc "广告主详情页面"
        get '/' do
          brand_user = current_kol.find_or_create_brand_user
          present :error, 0
          present :brand_amount, brand_user.avail_amount.to_f
        end

        desc "活动账单"
        get "/bill" do
          brand_user = current_kol.find_or_create_brand_user
          transactions = paginate(Kaminari.paginate_array(brand_user.paid_transactions.order('created_at DESC')))
          present :error, 0
          present :transactions, transactions, with: API::V1_4::Entities::TransactionEntities::TransactionEntity
        end

        desc '充值'
        post '/recharge' do
          error_403!(detail: "请联系客服绑定手机号。") if current_kol.mobile_number.blank?
          brand_user = current_kol.find_or_create_brand_user
          if params[:credits].to_i < MySettings.recharge_min_budget.to_i
            error_403!({error: 1, detail: "充值金额不能小于#{MySettings.recharge_min_budget}"})  and return
          end
          alipay_url = brand_user.generate_alipay_recharge_order_for_app(params[:credits],
            Rails.application.secrets[:alipay][:brand_recharge_notify_url])
          present :error, 0
          present :alipay_url, alipay_url
        end

        desc "支付宝回调"
        params do
          optional :out_trade_no, type: String
          optional :discount, type: String
          optional :payment_type, type: String
          optional :subject, type: String
          optional :trade_no, type: String
          optional :buyer_email, type: String
          optional :gmt_create, type: String
          optional :notify_type, type: String
          optional :quantity, type: String
          optional :seller_id, type: String
          optional :notify_time, type: String
          optional :body, type: String
          optional :trade_status, type: String
          optional :is_total_fee_adjust, type: String
          optional :total_fee, type: String
          optional :gmt_payment, type: String
          optional :seller_email, type: String
          optional :price, type: String
          optional :buyer_id, type: String
          optional :notify_id, type: String
          optional :use_coupon, type: String
          optional :sign_type, type: String
          optional :sign, type: String
        end
        post "/notify" do
          alipay_order = AlipayOrder.find_by :trade_no =>  params[:out_trade_no]
          content_type 'text/plain'
          unless alipay_order.present?
            body "error" and return
          end
          if alipay_order.status == "paid"
            body "success" and return
          end
          declared_params = declared(params).reject do |i| params[i].blank?  end
          if alipay_order.status == "pending" && Alipay::Sign.verify?(declared_params) && Alipay::Notify.verify?(declared_params)
            alipay_order.pay
            alipay_order.save_alipay_trade_no(params[:trade_no])
            body "success"
            return
          end
          body "error"
        end
      end
    end
  end
end
