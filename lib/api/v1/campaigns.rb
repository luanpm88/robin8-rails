module API
  module V1
    class Campaigns < Grape::API
      resources :campaigns do
        before do
          authenticate!
        end

        #获取活动信息 根据
        params do
          requires :id, type: Integer
        end
        get ':id' do
          campaign = Campaign.find(params[:id])            rescue nil
          if campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            campaign_invite = CampaignInvite.new(:campaign_id => campaign.id)
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/approve' do
          #TODO change to get from redis list
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif campaign_invite.status != 'running'
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.need_finish
            CampaignWorker.perform_async(@campaign.id, 'fee_end')
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite.approve
            present :error, 0
            present :campaign_invite, campaign_invite.reload, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end
      end
    end
  end
end
