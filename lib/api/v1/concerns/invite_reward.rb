module Concerns
  module InviteReward
    extend ActiveSupport::Concern

    def generate_invite_task_record
      # Inviter isn't rewarded unless Kol got approved in admin panel
      #return unless self.role_apply_status == 'passed'

      Rails.logger.transaction.info "--------generate_invite_task_record--------begin?-----"
      #device_exist如果为真，说明此用户有重复
      if self.IMEI.present?
        device_exist = Kol.where(:IMEI => self.IMEI).where("mobile_number != '#{Kol::TouristMobileNumber}'").size > 2
      elsif self.IDFA.present?
        device_exist = Kol.where(:IDFA => self.IDFA).where("mobile_number != '#{Kol::TouristMobileNumber}'").size > 2
      else
        device_exist = true
      end

      Rails.logger.transaction.info "--------generate_invite_task_record--------first return-----"
      # device_token_exist = Kol.where(:device_token => self.device_token).size > 1       #表示有重复
      return if self.app_platform.blank? || self.os_version.blank? || device_exist == true

      Rails.logger.transaction.info "--------generate_invite_task_record--------second return-----"
      # does not allow to proceed if user already had completed invitation
      return if RegisteredInvitation.completed.where(mobile_number: self.mobile_number).size > 0

      invitation = RegisteredInvitation.pending.where(mobile_number: self.mobile_number).take
      return unless invitation

      Rails.logger.transaction.info "--------generate_invite_task_record---#{self.id}-----IMEI:#{self.IMEI}---IDFA:#{self.IDFA}---exist:#{device_exist}"

      ActiveRecord::Base.transaction do
        inviter = invitation.inviter
        invitation.update!(status: 'completed', invitee_id: self.id, registered_at: Time.now)

        task_record = inviter.task_records.create(:task_type => RewardTask::InviteFriend, :status => 'active', :invitees_id => self.id)
        task_record.sync_to_transaction if inviter.today_invite_count <= 10
      end

      # download_invitation = DownloadInvitation.find_invation(self)
      # if download_invitation
      #   ActiveRecord::Base.transaction do
      #     inviter = download_invitation.inviter
      #     download_invitation.active_invitation
      #     task_record = inviter.task_records.create(:task_type => RewardTask::InviteFriend, :status => 'active', :invitees_id => self.id)
      #     task_record.sync_to_transaction    if inviter.today_invite_count <= 5
      #   end
      # else   #创建cpi_reg
      #   params = {app_platform: self.app_platform, app_version: self.app_version, os_version: self.os_version,
      #             device_model:self.device_model, reg_ip: self.current_sign_in_ip}
      #   data = {appid: Kol.get_official_appid, device_uuid: (self.IMEI || self.IDFA)}
      #   CpiReg.create_reg(params, data)
      # end
    end

  end
end
