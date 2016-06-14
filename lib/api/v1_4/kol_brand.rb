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
          present transactions
        end
      end
    end
  end
end