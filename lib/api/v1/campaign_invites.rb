module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'completed', 'missed', 'liked', 'waiting_upload' , 'countdown']
          optional :page, type: Integer
          optional :title, type: String
          optional :with_message_stat, type: String, values: ['y','n']
          optional :with_announcements, type: String
        end
        #TODO 使用搜索插件
        get '/' do
          @campaigns = nil
          if  params[:status] == 'all'
            applied_recruit_campaign_ids =
              if Campaign.where("deadline > ?", 7.days.ago).where(per_budget_type: 'recruit').blank?
                []
              else
                current_kol.campaign_invites.joins(:campaign).where("campaigns.deadline > '#{7.days.ago}' and campaigns.per_budget_type = 'recruit'").
                  where("campaign_invites.status in ('approved', 'finished')").collect{|t| t.campaign_id}
              end
            id_str = applied_recruit_campaign_ids.size > 0 ? applied_recruit_campaign_ids.join(",") : '""'

            search_criteria = ['unexecuted', 'agreed']
            search_criteria.push "countdown" if current_kol.app_version && current_kol.app_version >= "2.3.2"

            @campaigns = Campaign.where.not(status: search_criteria).where(id: current_kol.receive_campaign_ids.values).recent_7.order_by_status(id_str).page(params[:page]).per_page(10)
          elsif params[:status] == 'running'
            @campaigns = current_kol.running_campaigns.order_by_start.page(params[:page]).per_page(10)
          elsif params[:status] == 'waiting_upload'
            @campaign_invites = current_kol.campaign_invites.waiting_upload.page(params[:page]).per_page(10)
          elsif params[:status] == 'missed'
            @campaigns = current_kol.missed_campaigns.recent_7.order_by_start.page(params[:page]).per_page(10)
          elsif params[:status] == "countdown"
            @campaigns = Campaign.countdown.order_by_start.page(params[:page]).per_page(10)
          else
            @campaign_invites = current_kol.campaign_invites.includes(:campaign).send(params[:status]).order("campaign_invites.created_at desc")
                                .page(params[:page]).per_page(10)
          end

          if @campaigns
            @campaigns_filter = phone_filter(@campaigns)
            @campaign_invites = @campaigns_filter.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
          end

          to_paginate(@campaign_invites) unless @campaign_invites

          present :error,            0
          present :announcements,    Announcement.order_by_position, with: API::V1::Entities::AnnouncementEntities::Summary if params[:with_announcements] == 'y'
          present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
        end

        # 我的活动
        params do
          requires :status , type: String , values: ['pending','passed','rejected']
          optional :page, type: Integer
        end
        get 'my_campaigns' do
          if params[:status] == 'pending'
            kol_campaigns = current_kol.campaign_invites.where(status: ['approved','finished']).order(updated_at: :desc).page(params[:page]).per_page(10)
          else
            kol_campaigns = current_kol.campaign_invites.where(status: ['settled','rejected'] , img_status: params[:status]).order(updated_at: :desc).page(params[:page]).per_page(10)
          end
          present :error, 0
          to_paginate( kol_campaigns )
          present :my_campaigns, kol_campaigns , with: API::V1::Entities::CampaignInviteEntities::MyCampaigns
        end

        #活动邀请详情
        params do
          requires :id, type: Integer
          optional :invitee_page, type: Integer
        end
        get ':id' do
          campaign_invite = current_kol.campaign_invites.find(params[:id]) rescue nil
          campaign        = campaign_invite.campaign rescue nil

          if campaign_invite.blank? || campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            invitees_count, campaign_invites = CampaignInvite.get_invitees(campaign.id, params[:invitee_page])
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
            present :invitees_count,  invitees_count
            present :invitees,        campaign_invites.collect{|t| t.kol}, with: API::V1::Entities::KolEntities::InviteeSummary
            present :leader_club,     nil
          end
        end

        #接收活动邀请
        params do
          requires :id, type: Integer
        end
        put ':id/approve' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
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
            campaign_invite.reload
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          end
        end

        ## 上传截图
        params do
          requires :id, type: Integer
          # requires :screenshot, type: File   if !Rails.env.development?
          # optional :campaign_logo, type: File
        end
        put ':id/upload_screenshot' do
          # Rails.logger.geometry.info "---params:#{params}---kol:#{current_kol}---" if current_kol.admintags.include? Admintag.find(429)
          return error_403!({error: 1, detail: '该账户存在异常,请联系客服!' }) if current_kol.is_forbid?
          # params[:screenshot] = Rack::Test::UploadedFile.new(File.open("#{Rails.root}/app/assets/images/100.png"))  if Rails.env.development?
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          # elsif campaign_invite.can_upload_screenshot
          elsif true
            if params[:screenshot].present?
              url = "#{avatar_uploader params[:screenshot]},"
            else
              url = ""
              params.delete_if{|key , value| !(key.include? "screenshot") }.each do|image|
                url += "#{image[1].class == String ? image[1] : Uploader::FileUploader.image_uploader(image[1])},"
              end
            end
            campaign_invite.reupload_screenshot(url[0..-2])
            #是否进入自动审核
            # if params[:campaign_logo].present?
            #   campaign_invite.ocr_status, campaign_invite.ocr_detail = Ocr.get_result(campaign_invite, params)
            # end
            campaign_invite.save
            current_kol.generate_invite_task_record
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          else
            return error_403!({error: 1, detail: '该活动已错过上传截图时间' })
          end
        end

        # 转发活动
        params do
          requires :id, type: Integer
          optional :sub_type , type: String
        end
        put ':id/share' do

          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          elsif campaign_invite.status != 'running' && !campaign.is_recruit_type?
            return error_403!({error: 1, detail: '该营销活动已转发成功' })
          elsif campaign.need_finish
            CampaignWorker.perform_async(campaign.id, 'fee_end')
            return error_403!({error: 1, detail: '该活动已经结束！' })
          else
            campaign_invite = current_kol.share_campaign_invite(params[:id] , params[:sub_type])
            # 首次转发活动奖励
            alert = nil
            if current_kol.campaign_invites.count == 1 && current_kol.strategy[:first_task_bounty] > 0
              current_kol.income(current_kol.strategy[:first_task_bounty], 'first_task_bounty') if 
              alert = "由于您是 #{current_kol.strategy[:tag]} 的用户，额外赠送奖励#{current_kol.strategy[:first_task_bounty]}元"
            end
            # 当前用户的tag存在，且邀请好友的奖励大于0时
            if current_kol.strategy[:tag] && current_kol.strategy[:invite_bounty] > 0
              current_kol.generate_invite_task_record
              # 如果是点击型活动，将截图打一个标记，方便结算时自动通过
              campaign_invite.update_columns(screenshot: 'wait_pass') if campaign.is_click_type?
            end

            CampaignWorker.perform_async(campaign.id, 'fee_end') if campaign.need_finish
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
            present :alert, alert
          end
        end
      end
    end
  end
end
