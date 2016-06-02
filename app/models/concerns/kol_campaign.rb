module Concerns
  module KolCampaign
    extend ActiveSupport::Concern
    included do
      has_many :campaign_applies
    end

    class_methods do

    end

    def add_campaign_id(campaign_id, valid = true)
      if valid
        self.receive_campaign_ids << campaign_id unless self.receive_campaign_ids.include? campaign_id.to_s
      else
        self.receive_campaign_ids << campaign_id
      end
    end

    def delete_campaign_id(campaign_id)
      self.receive_campaign_ids.delete(campaign_id)
    end

    # 成功接收接收活动for pc
    def approve_campaign(campaign_id)
      campaign = Campaign.find campaign_id  rescue nil
      return if campaign.blank? || campaign.status != 'executing'  || !(self.receive_campaign_ids.include? "#{campaign_id}")
      campaign_invite = CampaignInvite.find_or_initialize_by(:campaign_id => campaign_id, :kol_id => self.id)
      if (campaign_invite && campaign_invite.status == 'running')  || campaign_invite.new_record?
        uuid = Base64.encode64({:campaign_id => campaign_id, :kol_id => self.id}.to_json).gsub("\n","")
        campaign_invite.approved_at = Time.now
        campaign_invite.status = 'approved'
        campaign_invite.img_status = 'pending'
        campaign_invite.uuid = uuid
        # campaign_invite.share_url = CampaignInvite.generate_share_url(uuid)
        # Rails.logger.error "----------share_url:-----#{campaign_invite.share_url}"
        campaign_invite.save
      end
      campaign_invite
    end

    #拆开 approve_campaign 先创建，再接收
    def receive_campaign(campaign_id)
      campaign = Campaign.find campaign_id  rescue nil
      return if campaign.blank? || campaign.status != 'executing'  || !(self.receive_campaign_ids.include? "#{campaign_id}")
      campaign_invite = CampaignInvite.find_or_initialize_by(:campaign_id => campaign_id, :kol_id => self.id)
      if (campaign_invite && campaign_invite.status == 'running')  || campaign_invite.new_record?
        uuid = Base64.encode64({:campaign_id => campaign_id, :kol_id => self.id}.to_json).gsub("\n","")
        campaign_invite.status = 'running'
        campaign_invite.img_status = 'pending'
        campaign_invite.uuid = uuid
        # campaign_invite.share_url = CampaignInvite.generate_share_url(uuid)
        campaign_invite.save
      end
      campaign_invite
    end


    # 成功转发活动
    def share_campaign_invite(campaign_invite_id)
      campaign_invite = CampaignInvite.find campaign_invite_id  rescue nil
      if campaign_invite && campaign_invite.status == 'running'
        campaign_invite.status = 'approved'
        campaign_invite.approved_at = Time.now
        campaign_invite.save
        campaign_invite.reload
      else
        nil
      end
    end

    # 待接收活动列表
    def running_campaigns
      approved_campaign_ids = CampaignInvite.where(:kol_id => self.id).where("status != 'running' or status != 'applying'").collect{|t| t.campaign_id}
      unapproved_campaign_ids = self.receive_campaign_ids.values.map(&:to_i) -  approved_campaign_ids
      campaigns = Campaign.where(:id => unapproved_campaign_ids).where(:status => 'executing')
      campaigns = campaigns.where("per_budget_type != 'recruit'")       if self.hide_recruit
      campaigns
    end

    # 已错过的活动       活动状态为finished \settled  且没接
    def missed_campaigns
      approved_campaign_ids = CampaignInvite.where(:kol_id => self.id).where("status != 'running'").collect{|t| t.campaign_id}
      unapproved_campaign_ids = self.receive_campaign_ids.values.map(&:to_i) -  approved_campaign_ids
      Campaign.completed.where(:id => unapproved_campaign_ids)
    end

    # 报名活动
    def apply_campaign(params)
      campaign_invite = nil
      ActiveRecord::Base.transaction  do
        campaign_id = params[:id]
        campaign = Campaign.find campaign_id  rescue nil
        return if campaign.blank? || campaign.status != 'executing'  || !(self.receive_campaign_ids.include? "#{campaign_id}")
        campaign_apply = self.campaign_applies.create(campaign_id: campaign_id, name: params[:name], phone: params[:phone],  weixin_no: params[:weixin_no],
                                     weixin_friend_count: params[:weixin_friend_count], status: 'applying', expect_price: params[:expect_price],
                                     remark:  params[:remark])
        Image.where(:id => params[:image_ids].split(",")).update_all(:referable_id => campaign_apply.id, :referable_type => campaign_apply.class.to_s)     if params[:image_ids].present?
        # 成功报名后，同步更改campaign_invites  等同于接收活动
        campaign_invite = CampaignInvite.find_or_initialize_by(:campaign_id => campaign_id, :kol_id => self.id)
        if campaign_invite.new_record?
          uuid = Base64.encode64({:campaign_id => campaign_id, :kol_id => self.id}.to_json).gsub("\n","")
          campaign_invite.campaign_apply_id = campaign_apply.id
          campaign_invite.status = 'applying'
          campaign_invite.img_status = 'pending'
          campaign_invite.uuid = uuid
          campaign_invite.save
        end
      end
      campaign_invite
    end

    def hide_recruit
      self.app_version < "1.2.0"  || self.app_version == "2"
    end
  end
end
