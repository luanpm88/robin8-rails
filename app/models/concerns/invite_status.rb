module Concerns
  module InviteStatus
    extend ActiveSupport::Concern
    # included do
    # end
    #
    # class_methods do
    # end

    def invite_status
      if status == 'running'
        'running'
      elsif status == 'applying'
        if Time.now < self.campaign.recruit_end_time
          'applying'
        else
          'end_apply'
        end
      elsif status == 'approved' && self.campaign.is_recruit_type?
        'executing'
      elsif status == 'approved'
        if !start_upload_screenshot
          'approved_and_unstart_upload'
        elsif img_status == 'pending' && screenshot.blank?
          'approved_and_can_upload'
        elsif img_status == 'pending' && screenshot.present?
          'approved_and_uploaded'
        elsif img_status == 'passed'
          'approved_and_passed'
        elsif img_status == 'rejected'
          'approved_and_rejected'
        else
          'unknown'
        end
      elsif status == 'finished'
        if !start_upload_screenshot
          'finished_and_unstart_upload'
        elsif img_status == 'pending' && screenshot.blank?
          'finished_and_can_upload'
        elsif img_status == 'pending' && screenshot.present?
          'finished_and_uploaded'
        elsif img_status == 'rejected'
          'finished_and_rejected'
        else
          'unknown'
        end
      elsif status == 'settled'
        'settled'
      elsif status == 'rejected'
        'rejected'
      elsif status == 'missed'
        'missed'
      else
        'unknown'
      end
    end
  end
end
