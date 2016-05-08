module Concerns
  module KolTask
    extend ActiveSupport::Concern
    included do
      has_many :task_records
      after_create :generate_invite_code
    end

    class_methods do

    end


    def had_complete_info?
      self.task_records.active.complete_info_records.size > 0
    end

    def had_favorable_comment?
      self.task_records.active.favorable_comment.size > 0
    end

    def today_had_check_in?
      self.task_records.active.check_in.today.size > 0
    end

    def check_in
      task_record = self.task_records.create(:task_type => RewardTask::CheckIn, :status => 'active')
      task_record.sync_to_transaction
    end

    def generate_invite_code
      while true
        invite_code = ((0..9).to_a + ('A'..'Z').to_a).sample(5).join("")
        code_exist = Kol.find_by(:invite_code => invite_code).present?
        if !code_exist
          self.update_column(:invite_code, invite_code)
          return
        end
      end
    end

    def invited_from(invite_code)
      return if invite_code.blank?
      inviter = Kol.find_by :invite_code => invite_code.upcase
      if inviter
        task_record = inviter.task_records.create(:task_type => RewardTask::InviteFriend, :status => 'active', :invitees_id => self.id  )
        task_record.sync_to_transaction
      end
    end

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

  end
end
