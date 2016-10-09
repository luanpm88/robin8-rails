module API
  module V1_4
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

        desc "智能发布活动"
        params do
          requires :url, type: String
          requires :expect_effect, type: String
        end
        post "analyze" do
          res = {}
          { :error => 0,
          }
        end
      end
    end
  end
end
