module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        get 'stat_summary' do
          invites = current_kol.campaign_invites.unrejected
          all_count = invites.size
          running_count = invites.running.size
          approved_count = invites.approved.size
          verifying_count = invites.verifying.size
          settled_count = invites.settled.size

          stat = {:all_count => all_count, :running_count => running_count, :approved_count => approved_count,
                  :verifying_count => verifying_count, :settled_count => settled_count }
          return {:error => 0, :stat => stat}
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'settled', 'liked']
        end
        get 'list' do
          if params[:status] == 'like'
            like_campaign_ids = current_user.love_campaign_likes.collect{|t| t.campaign_id }
            @campaign_invites = current_kol.campaign_invites.where(:campaign_id => like_campaign_ids )
          else
            hide_campaign_ids = current_kol.hide_campaign_likes.collect{|t| t.campaign_id }
            if params[:status] == 'all'
              @campaign_invites = current_kol.campaign_invites.unrejected.where.not(:campaign_id => hide_campaign_ids)
            else
              @campaign_invites = current_kol.campaign_invites.send(params[:status]).where.not(:campaign_id => hide_campaign_ids)
            end
          end
          @campaign_invites = @campaign_invites.page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(@campaign_invites)
          present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
        end

        params do
          requires :id, type: Integer
        end
        get ':id' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        params do
          requires :id, type: Integer
        end
        put ':id/approve' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif campaign_invite.status != 'running'
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收这次活动！' })
          elsif campaign.need_finish
            CampaignWorker.perform_async(@campaign.id, 'fee_end')
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite.update_attributes({status: 'approved', approved_at: Time.now})
            campaign_invite.reload
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

      end
    end
  end
end
