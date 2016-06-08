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
          requires :budget, type: Float
          requires :img, type: Hash
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          optional :message, type: String
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
        end
        post "/" do
          brand_user = current_kol.find_or_create_brand_user

          if params[:img]
            uploader = AvatarUploader.new
            uploader.store!(params[:img])
          end
          service = KolCreateCampaignService.new brand_user, declared(params).merge(:img_url => uploader.url)
          service.perform
          if service.errors.empty?
            campaign = brand_user.campaigns.last
            present :error, 0
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CreateCampaignEntity
          end
        end
      end
    end
  end
end