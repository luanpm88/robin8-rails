# encoding: utf-8
module API
  module V2_0
    class Credits < Grape::API
    	resources :credits do
        before do
          authenticate!
        end

        desc '我的积分流水'
        params do
          requires :page, type: Integer
        end
        get '/' do
          brand_user = current_kol.find_or_create_brand_user
          credits = paginate(Kaminari.paginate_array(brand_user.credits.order('created_at DESC')))
          present :error, 0
          present :credits, credits, with: Brand::V1::Entities::Credit
        end

      end
    end
  end
end