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
          present :error, 0
          present :announcements, Announcement.order_by_position, with: API::V1::Entities::AnnouncementEntities::Summary  if params[:with_announcements] == 'y'
          if  params[:status] == 'all'
            applied_recruit_campaign_ids =
              if Campaign.where("deadline > ?", 7.days.ago).where(per_budget_type: 'recruit').blank?
                []
              else
                current_kol.campaign_invites.joins(:campaign).where("campaigns.deadline > '#{7.days.ago}' and campaigns.per_budget_type = 'recruit'").
                  where("campaign_invites.status in ('approved', 'finished')" , campaign_status ).collect{|t| t.campaign_id}
              end
            id_str = applied_recruit_campaign_ids.size > 0 ? applied_recruit_campaign_ids.join(",") : '""'
            ids = current_kol.receive_campaign_ids.values
            @campaigns = Campaign.where("status != 'unexecuted' and status != 'agreed'").where(:id => ids).recent_7.order_by_status(id_str).page(params[:page]).per_page(10)
            @campaigns_filter = phone_filter(@campaigns)
            @campaign_invites = @campaigns_filter.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'running'
            @campaigns = current_kol.running_campaigns.order_by_start.page(params[:page]).per_page(10)
            @campaigns_filter = phone_filter(@campaigns)
            @campaign_invites = @campaigns_filter.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'waiting_upload'
            @campaign_invites = current_kol.campaign_invites.waiting_upload.page(params[:page]).per_page(10)
            to_paginate(@campaign_invites)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'missed'
            @campaigns = current_kol.missed_campaigns.recent_7.order_by_start.page(params[:page]).per_page(10)
            @campaigns_filter = phone_filter(@campaigns)
            @campaign_invites = @campaigns_filter.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == "countdown"
            @campaigns = Campaign.countdown.order_by_start.page(params[:page]).per_page(10)
            @campaigns_filter = phone_filter(@campaigns)
            @campaign_invites = @campaigns_filter.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          else
            @campaign_invites = current_kol.campaign_invites.send(params[:status]).order("campaign_invites.created_at desc")
                                .page(params[:page]).per_page(10)
            to_paginate(@campaign_invites)
            present :campaign_invites, @campaign_invites.includes(:campaign), with: API::V1::Entities::CampaignInviteEntities::Summary
          end
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
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          club_name = current_kol.club.club_name rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该活动不存在' })
          else
            invitees_count, campaign_invites = CampaignInvite.get_invitees(campaign.id, params[:invitee_page])
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
            present :invitees_count, invitees_count
            present :invitees, campaign_invites.collect{|t| t.kol}, with: API::V1::Entities::KolEntities::InviteeSummary
            present :leader_club, club_name
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
          return error_403!({error: 1, detail: '该账户存在异常,请联系客服!' }) if current_kol.is_forbid?
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
            # if params[:campaign_logo].present?
            #   campaign_invite.ocr_status, campaign_invite.ocr_detail = Ocr.get_result(campaign_invite, params)
            # end
            campaign_invite.save
            current_kol.generate_invite_task_record
            present :error, 0
            present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary
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
            CampaignWorker.perform_async(campaign.id, 'fee_end') if campaign.need_finish
            present :error, 0
            present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary
          end
        end
      end
    end
  end
end
