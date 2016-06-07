module API
  module V1_4
    class KolCampaign < Grape::API
      resources :kol_campaigns do
        before do
          authenticate!
        end

        desc 'Create a campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :url, type: String
          requires :img_url, type: String
          requires :budget, type: Float
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          optional :message, type: String
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
        end
        post "/" do
          brand_user = current_kol.find_or_create_brand_user
          service = KolCreateCampaignService.new brand_user, declared(params)
          service.perform
          if service.errors.empty?
            #brand_user.campaign.last
          end
        end
      end
    end
  end
end