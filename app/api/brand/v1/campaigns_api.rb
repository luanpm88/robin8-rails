module Brand
  module V1
    class CampaignsAPI < Base

      before do
        authenticate!
      end

      resource :campaigns do
        
        # short_url api should not placed in here. but now I don't know where to placed :(
        # and should placed before :id, otherwise grape will match :id not :short_url
        desc 'Generate short url by origin url and identifier'
        params do
          requires :url, type: String
          requires :identifier, type: String
        end
        get :short_url do
          # todo: should add execption handle
          action_url_params = declared params
          origin_action_url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{action_url_params[:identifier]}"
          short_url = ShortUrl.convert origin_action_url
        end

        desc 'Return a campaign by id'
        params do
          requires :id, type: Integer, desc: 'Campaign id'
        end
        get ':id' do
          present Campaign.find(params[:id])
        end

        desc 'Create a campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :url, type: String
          optional :img_url, type: String
          requires :budget, type: Float
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          optional :action_url_list, type: String
        end
        post do
          service = CreateCampaignService.new current_user, declared(params)

          if service.perform
            present service.campaign
          else
            error_unprocessable! service.first_error_message
          end
        end

        desc 'Update a campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :url, type: String
          optional :img_url, type: String
          requires :budget, type: Float
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          optional :action_url_list, type: String
        end
        put ':id' do
          service = UpdateCampaignService.new current_user, params[:id], declared(params)

          if service.perform
            present service.campaign
          else
            error_unprocessable! service.first_error_message
          end
        end
      end
    end
  end
end
