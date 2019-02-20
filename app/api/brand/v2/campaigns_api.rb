module Brand
  module V2
    class CampaignsAPI < Base
      include Grape::Kaminari

      group do
        before do
          authenticate!
        end
        resource :campaigns do

          paginate per_page: 4
          desc 'Get campaigns current user owns'
          get '/' do
            campaigns = paginate(Kaminari.paginate_array(current_user.campaigns.order('created_at DESC')))

            present campaigns, with: Entities::Campaign
          end

          desc "Create a campaign"
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
            requires :sub_type, type: String      #推广平台
            requires :example_screenshot_count, type: Integer
            requires :target, type: Hash do
              requires :age    , type:String
              requires :region , type:String
              requires :gender , type:String
              requires :tags   , type:String
            end
            optional :campaign_action_url, type: Hash do
              optional :action_url            , type: String
              optional :short_url             , type: String
              optional :action_url_identifier , type: String
            end
            requires :enable_append_push, type: String
          end
          post do
            if params[:budget].to_i < MySettings.campaign_min_budget.to_i
              error_unprocessable! "活动总预算不能低于#{MySettings.campaign_min_budget}元!"
              return
            end

            service = CreateCampaignService.new current_user, declared(params)
            Rails.logger.campaign_create.info "------user: #{current_user.id}------request_information: #{request.headers}"

            if service.perform
              present service.campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          desc "show a campaign"
          params do 
          end
          get "/:id" do
            campaign = current_user.campaigns.find_by_id params[:id]
            
            return {error: 1, detail: '数据错误，请确认'} unless campaign

            present campaign, with: Entities::Campaign
          end 

        end
      end
    end
  end
end