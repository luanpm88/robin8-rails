module CampaignHelper
  module RecruitCampaignServicePartial
    extend ActiveSupport::Concern
    def format_to_db_time
      @campaign_params[:recruit_start_time] = @campaign_params[:recruit_start_time].to_formatted_s(:db)
      @campaign_params[:recruit_end_time] = @campaign_params[:recruit_end_time].to_formatted_s(:db)
      @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
      @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)
    end

    def validate_recruit_time
      return if Rails.env.staging? or Rails.env.qa?

      if (@campaign_params[:recruit_end_time].to_time - @campaign_params[:recruit_start_time].to_time) < 24.hours
        @errors << '报名时间不能小于24小时'
      end

      if(@campaign_params[:start_time].to_time-@campaign_params[:recruit_end_time].to_time) < 24.hours
        @errors << '活动开始距离报名截止不能小于24小时'
      end
      if (@campaign_params[:deadline].to_time - @campaign_params[:start_time].to_time) < 1.hours
        @errors << '活动时间不能小于1小时'
      end
    end
  end
end
