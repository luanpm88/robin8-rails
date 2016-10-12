module API
  module V1_8
    class CampaignAnalysis < Grape::API
      resources :campaign_analysis do
        before do
          authenticate!
        end

        desc "获取活动期望效果列表"
        get "expect_effect_list" do
          present :error, 0
          present :expect_effect_list, Campaign::ExpectEffects
        end

        desc "活动分析"
        params do
          requires :url, type: String
          requires :expect_effect, type: String
        end
        post "content_analysis" do
          campaign_input, analysis_info =  Campaign.get_analysis_res(params[:url], params[:expect_effect])
          present :error, 0
          present :campaign_input, campaign_input, with: API::V1_4::Entities::CampaignEntities::CampaignStatsEntity
          present :analysis_info, analysis_info, with: API::V1_8::Entities::CampaignAnalysisEntities::AnalysisInfo
        end

        desc "参与人员分析"
        params do
          requires :campaign_id, type: Integer
        end
        get "invitee_analysis" do
          campaign = Campaign.find params[:campaign_id]
          present :error, 0
          present :gender_analysis, campaign.gender_analysis_of_invitee
          present :age_analysis, campaign.age_analysis_of_invitee
          present :tag_analysis, campaign.tag_analysis_of_invitee
          present :region_analysis, campaign.region_analysis_of_invitee
        end
      end
    end
  end
end
