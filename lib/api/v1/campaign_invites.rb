module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'completed', 'missed', 'liked']
          optional :page, type: Integer
          optional :title, type: String
          optional :with_message_stat, type: String, values: ['y','n']
        end
        #TODO 使用搜索插件
        get '/' do
          present :error, 0
          present :message_stat, current_kol, with: API::V1::Entities::KolEntities::MessageStat  if params[:with_message_stat] == 'y'
          if  params[:status] == 'all'
            @campaigns = Campaign.where("status != 'unexecuted' and status != 'agreed'").
              where(:id => current_kol.receive_campaign_ids.values).
              order_by_status.page(params[:page]).per_page(10)
            @campaign_invites = @campaigns.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
            present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
          elsif params[:status] == 'running'
            @campaigns = current_kol.running_campaigns.order_by_start.page(params[:page]).per_page(10)
            @campaign_invites = @campaigns.collect{|campaign| campaign.get_campaign_invite(current_kol.id) }
            to_paginate(@campaigns)
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
        end
        put ':id/upload_screenshot' do
          params[:screenshot] = Rack::Test::UploadedFile.new(File.open("#{Rails.root}/app/assets/images/100.png"))  if Rails.env.development?
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          elsif campaign_invite.can_upload_screenshot
            uploader = AvatarUploader.new
            uploader.store!(params[:screenshot])
            campaign_invite.screenshot = uploader.url
            campaign_invite.img_status = 'pending'
            campaign_invite.save
            return {:error => 0, :screenshot_url => uploader.url }
          else
            return error_403!({error: 1, detail: '该活动已经过了上传截图时间' })
          end
        end

        # 喜欢/不喜欢活动
        params do
          requires :id, type: Integer
        end
        put ':id/like' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          else
            campaign_like = CampaignAction.likes.find_by(:kol_id => current_kol.id, :campaign_id => campaign.id)
            liked = campaign_like.present?
            if liked
              if campaign_like.destroy
                return {:error => 0, :detail => '取消搜藏成功！'}
              else
                return {:error => 1, :detail => '取消搜藏失败，请联系管理员！'}
              end
            else
              campaign_like = CampaignAction.new(:kol_id => current_kol.id, :campaign_id => campaign.id, :action => 'like')
              if campaign_like.save
                return {:error => 0, :detail => '搜藏成功！'}
              else
                Rails.logger.error "---#{活动取消失败}---#{campaign_like.errors.full_message.inspect rescue nil}"
                return {:error => 1, :detail => '搜藏失败，请联系管理员！'}
              end
            end
          end
        end

        # 隐藏活动
        params do
          requires :id, type: Integer
        end
        put ':id/hide' do
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign = campaign_invite.campaign  rescue nil
          if campaign_invite.blank?  || campaign.blank?
            return error_403!({error: 1, detail: '该营销活动不存在' })
          else
            campaign_hide = CampaignAction.hides.find_by(:kol_id => current_kol.id, :campaign_id => campaign.id)
            hided = campaign_hide.present?
            #已经隐藏
            if hided
              if campaign_hide.destroy
                return {:error => 0, :detail => '取消隐藏成功！'}
              else
                return {:error => 1, :detail => '取消隐藏失败，请联系管理员！'}
              end
            else
              campaign_hide = CampaignAction.new(:kol_id => current_kol.id, :campaign_id => campaign.id, :action => 'hide')
              if campaign_hide.save
                return {:error => 0, :detail => '隐藏成功！'}
              else
                Rails.logger.error "---#{活动隐藏失败}---"
                return {:error => 1, :detail => '隐藏失败，请联系管理员！'}
              end
            end
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
          else
            campaign_invite.increment!(:share_count,1)
            return {:error => 0, :detail => '转发成功！'}
          end
        end
      end
    end
  end
end
