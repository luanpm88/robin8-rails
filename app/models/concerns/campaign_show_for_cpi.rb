module Concerns
  module CampaignShowForCpi
    extend ActiveSupport::Concern
    included do
      #for cpi
      Expired = 2.hours
      scope :effective, -> {where("created_at > '#{Expired.ago}'" ).where.not(:status => false)}
    end

    def generate_more_info
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
      def find_visit(cpi_reg)
        if cpi_reg.app_platform == "IOS"
          invitation = CampaignShow.effective.where(:visitor_ip => cpi_reg.reg_ip, :app_platform => cpi_reg.app_platform,
                                                    :os_version => cpi_reg.os_version).first
        else
          device_model = cpi_reg.device_model.strip.downcase.gsub(" ","")     rescue nil
          invitation = CampaignShow.effective.where(:visitor_ip => cpi_reg.reg_ip, :device_model => device_model,
                                                    :app_platform => cpi_reg.app_platform, :os_version => cpi_reg.os_version).first
        end
        invitation
      end

      def update_inviter(cpi_reg)
        invitation = find_inviter(cpi_reg)
        if invitation
          #need lock?
          invitation.status = true
          invitation.remark = 'cpi_reg'
          invitation.reg_time = Time.now
          invitation.remark = 'cpi_reg'
          cpi_reg.campaign_show_id = invitation.id
          cpi_reg.status = 'success'
          cpi_reg.save! && invitation.save!
        end
      end
    end
  end
end
