module Brand
  module V1
    class CampaignsAPI < Base

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
          uuid = Base64.encode64({ :campaign_action_url_identifier => action_url_params[:identifier], :step => '2'}.to_json).gsub("\n","")
          origin_action_url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"
          short_url = ShortUrl.convert origin_action_url
        end

        params do
          requires :campaign_id, type: String
        end
        get :statistics_clicks do
          campaign = Campaign.find params[:campaign_id]
          present campaign.get_stats
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
          requires :img_url, type: String
          requires :budget, type: Float
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          optional :message, type: String
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          requires :target, type: Hash do
            requires :age    , type:String
            requires :region , type:String
            requires :gender , type:String
          end
          optional :campaign_action_url, type: Hash do
            optional :action_url            , type: String
            optional :short_url             , type: String
            optional :action_url_identifier , type: String
          end
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
          requires :img_url, type: String
          requires :budget, type: Float
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          optional :message, type: String
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          requires :target, type: Hash do
            requires :age    , type:String
            requires :region , type:String
            requires :gender , type:String
          end
          optional :campaign_action_url, type: Hash do
            optional :action_url            , type: String
            optional :short_url             , type: String
            optional :action_url_identifier , type: String
          end
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

      desc 'Create a recruit campaign'
      params do
        requires :name, type: String
        requires :description, type: String
        requires :task_description, type: String
        optional :address, type: String
        requires :img_url, type: String
        requires :region, type: String
        requires :influence_score, type: String
        requires :recruit_start_time, type: DateTime
        requires :recruit_end_time, type: DateTime
        requires :start_time, type: DateTime
        requires :deadline, type: DateTime
        requires :per_action_budget, type: Float
        requires :recruit_person_count, type: Float
        optional :budget,   type: Float
      end
      post 'recruit_campaigns' do
        params[:budget] = params[:recruit_person_count] * params[:per_action_budget]
        service = CreateRecruitCampaignService.new current_user, declared(params)
        if service.perform
          present service.campaign
        else
          error_unprocessable! service.first_error_message
        end
      end

      desc 'Update a recruit campaign'
      params do
        requires :name, type: String
        requires :description, type: String
        requires :task_description, type: String
        optional :address, type: String
        requires :img_url, type: String
        requires :region, type: String
        requires :influence_score, type: String
        requires :recruit_start_time, type: DateTime
        requires :recruit_end_time, type: DateTime
        requires :start_time, type: DateTime
        requires :deadline, type: DateTime
        requires :per_action_budget, type: Float
        requires :budget, type: Float
      end
      put '/recruit_campaigns/:id' do
        service = UpdateRecruitCampaignService.new current_user, params[:id], declared(params)
        if service.perform
          present service.campaign
        else
          error_unprocessable! service.first_error_message
        end
      end

      desc "Get a recruit_campaign"
      params do
        requires :id, type: Integer
      end
      get '/recruit_campaigns/:id' do
        present Campaign.find_by(id: declared(params)[:id])
      end

      desc "change recruit_campaign's 'end_apply_check' status "
      params do
        requires :id, type: Integer
      end
      put "/recruit_campaigns/:id/end_apply_check" do
        CampaignApply.end_apply_check(declared(params)[:id])
      end
    end
  end
end
