module API
  module V1
    class Campaigns < Grape::API
      resources :campaigns do
        before do
          action_name =  @options[:path].join("")
          authenticate! if action_name != ':id'
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
            campaign_invite = campaign.get_campaign_invite(current_kol.try(:id))
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/approve' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !current_kol.receive_campaign_ids.include?("#{params[:id]}")
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif campaign.status != 'executing' || (campaign_invite && campaign_invite.status != 'running')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.need_finish
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite = current_kol.approve_campaign(params[:id])
            campaign_invite = campaign_invite.reload
            CampaignWorker.perform_async(campaign.id, 'fee_end') if campaign.need_finish
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/receive' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !current_kol.receive_campaign_ids.include?("#{params[:id]}")
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif campaign.status != 'executing' || (campaign_invite && campaign_invite.status != 'running')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.need_finish
            CampaignWorker.perform_async(campaign.id, 'fee_end')
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite = current_kol.receive_campaign(params[:id])
            campaign_invite = campaign_invite.reload
            if current_kol.app_platform == "IOS"
              campaign_invite.campaign.url = campaign_invite.origin_share_url
            end
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        #活动报名预审
        params do
          requires :id, type: Integer
        end
        put 'can_apply' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !campaign.is_recruit_type? || !current_kol.receive_campaign_ids.include?("#{params[:id]}")
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif !campaign.can_apply ||  campaign.status != 'executing' || (campaign_invite && campaign_invite.status != 'applying')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.influence_score_target && current_kol.influence_score.to_i < campaign.influence_score_target.get_score_value
            return error_403!({error: 1, detail: "抱歉，本次活动不接受影响力分数低于 #{campaign.influence_score_target.get_score_value}的KOL用户报名" })
          else
            present :error, 0
            present :process, Campaign::OfflineProcess
            present :binded_weibo, current_kol.identities.provider('weibo').size > 0
          end
        end

        #活动报名
        params do
          requires :id, type: Integer
          requires :name, type: String
          requires :phone, type: String
          requires :weixin_no, type: String
          requires :weixin_friend_count, type: Integer
          requires :expect_price, type: String
        end
        put 'apply' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !campaign.is_recruit_type? || !current_kol.receive_campaign_ids.include?("#{params[:id]}")
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif !campaign.can_apply ||  campaign.status != 'executing' || campaign_invite.present?
            return error_403!({error: 1, detail: '该活动已过报名时间或者您已经接收本次活动！' })
          elsif campaign.influence_score_target && current_kol.influence_score.to_i < campaign.influence_score_target.get_score_value
            return error_403!({error: 2, detail: "抱歉，本次活动不接受影响力分数低于 #{campaign.influence_score_target.get_score_value}的KOL用户报名" })
          else
            campaign_invite = current_kol.apply_campaign(params)
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end
      end
    end
  end
end
