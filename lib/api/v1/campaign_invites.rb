module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'completed', 'missed', 'liked', 'waiting_upload']
          optional :page, type: Integer
          optional :title, type: String
          optional :with_message_stat, type: String, values: ['y','n']
          optional :with_announcements, type: String
        end
        #TODO 使用搜索插件
        get '/' do
          present :error, 0
          present :message_stat, current_kol, with: API::V1::Entities::KolEntities::MessageStat  if params[:with_message_stat] == 'y'
          present :announcements, Announcement.order_by_position, with: API::V1::Entities::AnnouncementEntities::Summary  if params[:with_announcements] == 'y'
          if  params[:status] == 'all'
            if current_kol.hide_recruit
              @campaigns = Campaign.where("status != 'unexecuted' and status != 'agreed'").where("per_budget_type != 'recruit'")
              @campaigns =  @campaigns.where(:id => current_kol.receive_campaign_ids.values).
                order_by_status.page(params[:page]).per_page(10)
            else
              @campaigns = Campaign.where("status != 'unexecuted' and status != 'agreed'").where(:id => current_kol.receive_campaign_ids.values).
                order_by_status.page(params[:page]).per_page(10)
            end
            @campaign_invites = @campaigns.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'running'
            @campaigns = current_kol.running_campaigns.order_by_start.page(params[:page]).per_page(10)
            @campaign_invites = @campaigns.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'waiting_upload'
            @campaign_invites = current_kol.campaign_invites.waiting_upload.page(params[:page]).per_page(10)
            to_paginate(@campaign_invites)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'missed'
            @campaigns = current_kol.missed_campaigns.order_by_start.page(params[:page]).per_page(10)
            @campaign_invites = @campaigns.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          else
            @campaign_invites = current_kol.campaign_invites.send(params[:status]).order("campaign_invites.created_at desc")
                                .page(params[:page]).per_page(10)
            to_paginate(@campaign_invites)
            present :campaign_invites, @campaign_invites.includes(:campaign), with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        #活动邀请详情
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
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end

        ## 上传截图
        params do
          requires :id, type: Integer
          # requires :screenshot, type: File   if !Rails.env.development?
          # optional :campaign_logo, type: File
        end
        put ':id/upload_screenshot' do
          # params[:screenshot] = Rack::Test::UploadedFile.new(File.open("#{Rails.root}/app/assets/images/100.png"))  if Rails.env.development?
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          elsif campaign_invite.can_upload_screenshot
            uploader = AvatarUploader.new
            uploader.store!(params[:screenshot])
            campaign_invite.reupload_screenshot(uploader.url)
            #是否进入自动审核
            if params[:campaign_logo].present?
              campaign_invite.ocr_status, campaign_invite.ocr_detail = Ocr.get_result(campaign_invite, params)
            end
            campaign_invite.save
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
          else
            return error_403!({error: 1, detail: '该活动已错过上传截图时间' })
          end
        end

        # 转发活动
        params do
          requires :id, type: Integer
        end
        put ':id/share' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          elsif campaign_invite.status != 'running'
            return error_403!({error: 1, detail: '该营销活动已转发成功' })
          else
            campaign_invite = current_kol.share_campaign_invite(params[:id])
            CampaignWorker.perform_async(campaign.id, 'fee_end') if campaign.need_finish
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end
      end
    end
  end
end
