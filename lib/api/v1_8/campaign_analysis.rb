module API
  module V1_8
    class CampaignAnalysis < Grape::API
      resources :campaign_analysis do
        before do
          authenticate!
        end

        desc "获取活动期望效果"
        get "expect_effect_list" do
          present :error, 0
          present :expect_effect_list, Campaign::ExpectEffects
        end

        desc "活动分析"
        params do
          requires :url, type: String
          requires :expect_effect, type: String
        end
        post "analysis" do
          campaign_input, analysis_info =  Campaign.get_analysis_res(params[:url], params[:expect_effect])
          present :error, 0
          present :campaign_input, campaign_input, with: API::V1_4::Entities::CampaignEntities::CampaignStatsEntity
          present :analysis_info, analysis_info, with: API::V1_8::Entities::CampaignAnalysisEntities::AnalysisInfo
        end
      end
    end
  end
end
