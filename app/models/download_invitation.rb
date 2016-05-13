class DownloadInvitation < ActiveRecord::Base
  belongs_to :inviter, :foreign_key => 'inviter_id', :class_name => 'Kol'
  before_save :generate_os_and_model, :on => :create
  Expired = 2.hours
  scope :effective, -> {where("created_at > '#{Expired.ago}'" ).where(:effective => false)}

  def self.find_invation(kol)
    if kol.app_platform == "IOS"
      download_invitation = DownloadInvitation.effective.where(:visitor_ip => kol.current_sign_in_ip, :app_platform => kol.app_platform,
                                                               :os_version => kol.os_version).first
    else
      download_invitation = DownloadInvitation.effective.where(:visitor_ip => kol.current_sign_in_ip, :device_model => kol.device_model,
                                                               :app_platform => kol.app_platform, :os_version => kol.os_version).first
    end
    download_invitation
  end

  def active_invitation
    self.update_column(:effective , true)
  end

  def generate_os_and_model
    return if self.os_version.present? && self.device_model.present?
    if self.visitor_agent.downcase.include?("iphone")
      self.app_platform = 'IOS'
      res =self.visitor_agent.match(/\s\(.*?OS\s(.*?)\slike/)
      self.os_version = res[1].split("_").join(".")
    elsif self.visitor_agent.downcase.include?("android")
      self.app_platform = 'Android'
      res = self.visitor_agent.match(/\s\(.*Android\s(.*?);(.*;)?(.*)\sBuild/)
      self.os_version = res[1]
      self.device_model = res[3]
    end
  end


end
