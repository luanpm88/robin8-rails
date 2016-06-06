module API
  module V1_4
    class KolCampaign < Grape::API
      resources :kol_campaigns do
        before do
          authenticate!
        end

        post "/" do
          brand_user = current_user.find_or_create_brand_user
          service = CreateCampaignService.new brand_user, declared(params)
        end
      end
    end
  end
end