module API
  module V1_6
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end
        #拒绝特邀活动
        params do
          requires :id, type: Integer
        end
        post ':id/reject' do
          campaign_invite = CampaignInvite.where(:id => params[:id]).first  rescue nil
          campaign = campaign_invite.campaign
          if campaign.blank? || !campaign.is_invite_type? || campaign_invite.blank?
            return error_403!({error: 1, detail: '该活动不存在,或者该活动不能拒绝' })
          elsif campaign.status != 'executing' || (campaign_invite && campaign_invite.status != 'running')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          else
            campaign_invite = current_kol.reject_campaign_invite(campaign_invite)
            present :error, 0
            present :campaign_invite, campaign_invite.reload, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

      end
    end
  end
end
