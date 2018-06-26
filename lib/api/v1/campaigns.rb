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
          optional :invitee_page, type: Integer
        end
        get ':id' do
          campaign = Campaign.find(params[:id])            rescue nil
          club_name = current_kol.club.club_name rescue nil
          if campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            campaign_invite = campaign.get_campaign_invite(current_kol.try(:id))
            invitees_count, campaign_invites = CampaignInvite.get_invitees(params[:id], params[:invitee_page])
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
            present :invitees_count, invitees_count
            present :invitees, campaign_invites.collect{|t| t.kol}, with: API::V1::Entities::KolEntities::InviteeSummary
            present :leader_club, club_name
          end
        end

        #获取活动参与人员信息
        params do
          requires :id, type: Integer
          optional :invitee_page, type: Integer
        end
        get ':id/invitees' do
          campaign = Campaign.find(params[:id])            rescue nil
          if campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            total_count, campaign_invites = CampaignInvite.get_invitees(params[:id], params[:invitee_page])
            present :error, 0
            to_paginate(campaign_invites)
            present :invitees, campaign_invites.collect{|t| t.kol}, with: API::V1::Entities::KolEntities::InviteeSummary
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/approve' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !current_kol.receive_campaign_ids.include?("#{params[:id]}") || campaign.is_recruit_type?
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif campaign.status != 'executing' || (campaign_invite && campaign_invite.status != 'running')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.need_finish
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite = current_kol.approve_campaign(params[:id])
            campaign_invite.reload
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/receive' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          last_approved_invite = CampaignInvite.where(:kol_id => current_kol.id).where("approved_at is not null").order("approved_at desc").first      rescue nil
          today_approved_invite_count = CampaignInvite.where(:kol_id => current_kol.id).where("approved_at > '#{Date.today}'").count
          if campaign.blank? || !current_kol.receive_campaign_ids.include?("#{params[:id]}")  || campaign.is_recruit_type?
            return error_403!({error: 1, detail: '该活动不存在' })
          elsif ['executing', 'countdown'].exclude?(campaign.status) ||  (campaign_invite && campaign_invite.status != 'running')
          # elsif campaign.status != 'executing' ||  (campaign_invite && campaign_invite.status != 'running')
            return error_403!({error: 1, detail: '该活动已经结束或者您已经接收本次活动！' })
          elsif campaign.need_finish
            CampaignWorker.perform_async(campaign.id, 'fee_end')
            return error_403!({error: 1, detail: '该活动已经结束！' })
          elsif Rails.env.production? && !Kol::AdminKolIds.include?(current_kol.id) && last_approved_invite.present? && last_approved_invite.approved_at > (Time.now - 30.minutes)
            return error_403!({error: 1, detail: '距上次接活动间隔需大于30分钟!' })
          # elsif !Kol::AdminKolIds.include?(current_kol.id) && !current_kol.is_big_v? && (campaign.is_post_type? || campaign.is_cpa_type?)
          #   return error_403!({error: 1, detail: '您还未申请成为KOL,不能接收转发类型活动!' })
          # elsif !Kol::AdminKolIds.include?(current_kol.id) && !current_kol.is_big_v? && today_approved_invite_count >= 2
          #   return error_403!({error: 1, detail: '您还未申请成为KOL,每天只能接2个活动!' })
          elsif !Kol::AdminKolIds.include?(current_kol.id) && current_kol.is_big_v? && today_approved_invite_count >= 4
            return error_403!({error: 1, detail: '为了提高广告质量,每天只能接4个活动!' })
          else
            campaign_invite = current_kol.receive_campaign(params[:id])
            return error_403!({error: 1, detail: '分享失败了,请重试!' })    if campaign_invite.try(:id).nil?
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          end
        end

        #活动报名预审
        params do
          requires :id, type: Integer
        end
        put 'can_apply' do
          campaign = Campaign.find(params[:id]) rescue nil
          campaign_invite = current_kol.campaign_invites.where(:campaign_id => params[:id]).first  rescue nil
          if campaign.blank? || !campaign.is_recruit_type? ||  current_kol.app_version < '1.2.0' || !current_kol.receive_campaign_ids.include?("#{params[:id]}")
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
          optional :name, type: String
          optional :phone, type: String
          optional :weixin_no, type: String
          optional :weixin_friend_count
          optional :expect_price, type: String
          optional :remark, type: String
          optional :image_ids, type: String
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
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          end
        end
      end
    end
  end
end
