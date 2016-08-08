module API
  module V1_6
    class Campaigns < Grape::API
      resources :campaigns do
        #获取活动素材
        params do
          requires :id, type: Integer
        end
        get ':id/materials' do
          campaign = Campaign.find(params[:id])            rescue nil
          if campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            campaign_materials = campaign.campaign_materials
            present :error, 0
            present :campaign_materials, campaign_materials, with: API::V1_6::Entities::CampaignMaterialEntities::Summary
          end
        end
      end
    end
  end
end
