module Brand
  module V1
    class CampaignsAPI < Base

      resource :campaigns do
        
        desc 'Return a campaign by id'
        params do
          requires :id, type: Integer, desc: 'Campaign id'
        end
        route_param :id do
          get do
            present Campaign.find(params[:id])
          end
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

      end

    end
  end
end
