module Brand
  module V2
    class CampaignsAPI < Base
      include Grape::Kaminari

      group do
        before do
          authenticate!
        end
        resource :campaigns do

          params do
            requires :campaign_id, type: Integer
          end
          get "statistics_clicks" do
            campaign = Campaign.find params[:campaign_id]
            present campaign.get_stats
          end

          # paginate per_page: 10
          desc 'Get campaigns current user owns'
          get '/' do
            campaigns = paginate(Kaminari.paginate_array(current_user.campaigns.order('created_at DESC')))

            present campaigns, with: Entities::Campaign
          end

          desc "Create or Update a campaign"
          params do
            optional :id, type: Integer
            requires :name, type: String                      #活动标题
            requires :description, type: String               #活动简介
            requires :url, type: String                       #活动链接
            requires :img_url, type: String                   #活动图片
            requires :budget, type: Float                     #活动总预算
            requires :per_budget_type, type: String           #奖励模式选择(click:按照点击奖励KOL, post:按照转发奖励KOL, cpt:按照完成任务奖励KOL)
            requires :per_action_budget, type: Float          #单次预算
            optional :message, type: String                   #备注信息
            requires :start_time, type: DateTime              #活动开始时间
            requires :deadline, type: DateTime                #活动结束时间
            requires :sub_type, type: String                  #推广平台(wechat,weibo)
            requires :example_screenshot_count, type: Integer #示例图片数量
            requires :target, type: Hash do
              requires :age    , type:String
              requires :region , type:String
              requires :gender , type:String
              requires :tags   , type:String
            end
            requires :enable_append_push, type: String
          end
          post "" do
            if params[:budget].to_i < MySettings.campaign_min_budget.to_i
              error_unprocessable! "活动总预算不能低于#{MySettings.campaign_min_budget}元!"
              return
            end

            if params[:id] && current_user.campaigns.find_by_id(params[:id])
              service = UpdateCampaignService.new current_user, params[:id], declared(params)
            else
              service = CreateCampaignService.new current_user, declared(params)
              Rails.logger.campaign_create.info "------user: #{current_user.id}------request_information: #{request.headers}"
            end

            if service.perform
              present service.campaign, with: Entities::Campaign
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

          desc 'evaluate  campaign  info'
          params do
            requires :review_content, type: String
            requires :effect_score, type: Integer
          end
          post ':id/evaluate' do
            @campaign = Campaign.find params[:id]
            if @campaign.evaluation_status != "evaluating"
              return {error: 1, detail: '该活动你已评价,或暂时不能评价!'}
            end
            CampaignEvaluation.evaluate(@campaign, params[:effect_score], params[:experience_score], params[:review_content])
            present @campaign, with: Entities::Campaign
          end

        end
      end
    end
  end
end