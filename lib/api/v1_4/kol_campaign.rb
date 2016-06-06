module API
  module V1_4
    class KolCampaign < Grape::API
      resources :kol_campaigns do
        before do
          authenticate!
        end

        post "create" do
          
        end
      end
    end
  end
end