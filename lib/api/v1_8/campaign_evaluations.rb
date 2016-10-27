module API
  module V1_8
    class CampaignEvaluations < Grape::API
      resources :campaign_evaluations do
        before do
          authenticate!
        end

        desc "评价活动"
        params do
          requires :campaign_id, type: Integer
          requires :effect_score, type: Integer
          optional :experience_score, type: Integer
          requires :review_content, type: String
        end
        post 'evaluate' do
          campaign = Campaign.find params[:campaign_id]
          if campaign.blank? || campaign.evaluation_status != 'evaluating'
            error_403!({error: 1, detail: "该活动不存在,或还未结算"})
          elsif campaign.user_id != current_kol.find_or_create_brand_user.try(:id)
            error_403!({error: 1, detail: "该活动您不能评价"})
          end
          CampaignEvaluation.evaluate(campaign, params[:effect_score], params[:experience_score], params[:review_content])
          present :error, 0
        end
      end
    end
  end
end
