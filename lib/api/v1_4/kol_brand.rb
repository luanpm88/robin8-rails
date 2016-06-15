module API
  module V1_4
    class KolBrand < Grape::API
      resources :kol_brand do
        before do
          action_name =  @options[:path].join("")
          authenticate!
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
        post do
          brand_user = current_kol.find_or_create_brand_user
          if params[:credits].to_i <= 500
            error_403!({error: 1, detail: "充值金额不能小于500"})  and return
          end
          alipay_url = brand_user.generate_alipay_recharge_order_for_app params[:credits]
          present :error, 0
          present :alipay_url, alipay_url
        end
      end

      desc "支付宝回调"
    end
  end
end