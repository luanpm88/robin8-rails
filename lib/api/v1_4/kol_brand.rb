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
          present :brand_amount, brand_user.amount.to_f
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
          brand_user = current_kol.find_or_create_brand_user
          if params[:credits].to_i < 500
            error_403!({error: 1, detail: "充值金额不能小于500"})  and return
          end
          alipay_url = brand_user.generate_alipay_recharge_order_for_app params[:credits]
          present :error, 0
          present :alipay_url, alipay_url
        end
      end

      desc "支付宝回调"
      params do
        requires :out_trade_no, type: String
        requires :discount, type: String
        requires :payment_type, type: String
        requires :subject, type: String
        requires :trade_no, type: String
        requires :buyer_email, type: String
        requires :gmt_create, type: String
        requires :notify_type, type: String
        requires :quantity, type: String
        requires :seller_id, type: String
        requires :notify_time, type: String
        requires :body, type: String
        requires :trade_status, type: String
        requires :is_total_fee_adjust, type: String
        requires :total_fee, type: String
        requires :gmt_payment, type: String
        requires :seller_email, type: String
        requires :price, type: String
        requires :buyer_id, type: String
        requires :notify_id, type: String
        requires :use_coupon, type: String
        requires :sign_type, type: String
        requires :sign, type: String
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

        if alipay_order.status == "pending" && Alipay::Sign.verify?(declared(params)) && Alipay::Notify.verify?(declared(params))
          alipay_order.pay
          body "success"
          return
        end
        body "error"
      end
    end
  end
end