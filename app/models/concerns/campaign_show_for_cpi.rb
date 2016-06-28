module Concerns
  module CampaignShowForCpi
    extend ActiveSupport::Concern
    included do
      Expired = 2.hours
      scope :effective, -> {where("created_at > '#{Expired.ago}'" ).where(:status => false)}
    end

    def generate_more_info
      return self if self.visitor_agent.blank?
      if self.visitor_agent.downcase.include?("iphone")
        self.app_platform = 'IOS'
        res = self.visitor_agent.match(/\s\(.*?OS\s(.*?)\slike/)
        self.os_version = res[1].split("_").join(".")
      elsif self.visitor_agent.downcase.include?("android")
        self.app_platform = 'Android'
        res = self.visitor_agent.match(/\s\(.*Android\s(.*?);(.*;)?(.*)\sBuild/)
        self.os_version = res[1]
        self.device_model = res[3].strip.downcase.gsub(" ","")     rescue nil
      end
      self
    end

    class_methods do
      #for cpi
      def find_visit(cpi_reg)
        if cpi_reg.app_platform == "IOS"
          invitation = CampaignShow.effective.where(:visitor_ip => cpi_reg.reg_ip, :app_platform => cpi_reg.app_platform, :appid => cpi_reg.appid,
                                                    :os_version => cpi_reg.os_version).first
        else
          device_model = cpi_reg.device_model.strip.downcase.gsub(" ","")     rescue nil
          invitation = CampaignShow.effective.where(:visitor_ip => cpi_reg.reg_ip, :device_model => device_model, :appid => cpi_reg.appid,
                                                    :app_platform => cpi_reg.app_platform, :os_version => cpi_reg.os_version).first
        end
        invitation
      end

      def update_inviter(cpi_reg)
        invitation = find_visit(cpi_reg)
        if invitation
          #need lock?
          #更新 avail_click
          campaign = invitation.campaign
          campaign_invite = CampaignInvite.find_by(:campaign_id => invitation.campaign_id, :kol_id => invitation.kol_id)
          if campaign_invite && campaign && campaign.status == 'executing' && campaign.redis_total_click <= campaign.max_action
            invitation.status = true
            invitation.remark = 'cpi_reg'
            invitation.reg_time = Time.now
            cpi_reg.campaign_show_id = invitation.id
            cpi_reg.status = 'success'
            cpi_reg.save! && invitation.save!
            campaign_invite.add_click(true,'cpi_reg')
            campaign.add_click(true)
          else
            #invitation status not update to true
            invitation.remark = 'cpi_reg'
            invitation.reg_time = Time.now
            cpi_reg.campaign_show_id = invitation.id
            cpi_reg.status = 'success'
            cpi_reg.save! && invitation.save!
          end
        end
      end
    end
  end
end
