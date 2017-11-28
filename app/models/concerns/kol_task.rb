module Concerns
  module KolTask
    extend ActiveSupport::Concern
    included do
      has_many :task_records
      has_many :invite_transactions, ->{where(:subject => RewardTask::InviteFriend).order('created_at desc')}, :as => :account, :class_name => 'Transaction'
      # after_create :generate_invite_code

      # Kol's inviter is rewarded only after Kol gets approved
      #after_create :generate_invite_task_record
      #after_update :generate_invite_task_record
    end

    class_methods do

    end


    def had_complete_reward?
      self.task_records.active.complete_info.size > 0
    end

    def had_favorable_comment?
      self.task_records.active.favorable_comment.size > 0
    end

    def today_had_check_in?
      self.task_records.active.check_in.today.size > 0
    end

    def today_invite_count
      self.task_records.invite_friend.today.count
    end

    def check_in
      task_record = self.task_records.create(:task_type => RewardTask::CheckIn, :status => 'active')
      task_record.sync_to_transaction
    end

    def invite_count
      task_records.invite_friend.count
    end

    def generate_invite_task_record
      # Inviter isn't rewarded unless Kol got approved in admin panel
      #return unless self.role_apply_status == 'passed'

      #device_exist如果为真，说明此用户有重复
      if self.IMEI.present?
        device_exist = Kol.where(:IMEI => self.IMEI).where("mobile_number != '#{Kol::TouristMobileNumber}'").size > 2
      elsif self.IDFA.present?
        device_exist = Kol.where(:IDFA => self.IDFA).where("mobile_number != '#{Kol::TouristMobileNumber}'").size > 2
      else
        device_exist = true
      end

      # device_token_exist = Kol.where(:device_token => self.device_token).size > 1       #表示有重复
      return if self.app_platform.blank? || self.os_version.blank? || device_exist == true

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
    end

    # def generate_invite_code
    #   return if invite_code.present?
    #   while true
    #     invite_code = ((0..9).to_a + ('A'..'Z').to_a).sample(5).join("")
    #     code_exist = Kol.find_by(:invite_code => invite_code).present?
    #     if !code_exist
    #       self.update_column(:invite_code, invite_code)
    #       return
    #     end
    #   end
    # end

    # def invited_from(invite_code)
    #   return if invite_code.blank?
    #   inviter = Kol.find_by :invite_code => invite_code.upcase
    #   if inviter
    #     task_record = inviter.task_records.create(:task_type => RewardTask::InviteFriend, :status => 'active', :invitees_id => self.id  )
    #     task_record.sync_to_transaction
    #   end
    # end

    def complete_info
      task_record = self.task_records.create(:task_type => RewardTask::CompleteInfo, :status => 'active')
      task_record.sync_to_transaction
    end

    def upload_comment_screenshot  screenshot
      self.task_records.create(:task_type => RewardTask::FavorableComment, :screenshot => screenshot, :status => 'pending')
    end

    def favorable_comment
      task_record = self.task_records.create(:task_type => RewardTask::CheckIn)
      task_record.sync_to_transaction
    end

    def checkin_history
      task_records.check_in.active.created_desc.where("created_at >= '#{Date.today.beginning_of_month}'").collect{|t| t.created_at.to_date }
    end

    def continuous_checkin_count
      _count = 0
      _start = Date.yesterday
      last_30_check_in_date = task_records.check_in.active.created_desc.where("created_at < '#{Date.today}'").limit(30).collect{|t| t.created_at.to_date }
      (0..30).to_a.each do |i|
        if last_30_check_in_date[i] == (_start - i.days)
          _count += 1
        else
          break
        end
      end
      _count += 1 if today_had_check_in?
      _count
    end

    def profile_complete?
      avatar_url.present? && name.present? && gender.present? && gender != 0 && age.present? && app_city.present? && tags.size > 0 &&
        weixin_friend_count.present? && mobile_number.present? && identities.size > 0
    end

    def can_receive_complete_reward
      !had_complete_reward?  && profile_complete?
    end

  end
end
