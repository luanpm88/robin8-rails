module API
  module V1_6
    class Campaigns < Grape::API
      resources :campaigns do
        #获取活动素材
        params do
          optional :campaign_id, type: Integer
          optional :campaign_invite_id, type: Integer
        end
        get 'materials' do
          if params[:campaign_id]
            campaign = Campaign.find(params[:campaign_id])            rescue nil
          else
            campaign = CampaignInvite.find(params[:campaign_invite_id]).campaign            rescue nil
          end
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
