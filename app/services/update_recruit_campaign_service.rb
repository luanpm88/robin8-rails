class UpdateRecruitCampaignService
  PERMIT_PARAMS = [:name, :description, :task_description, :url, :img_url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :region, :influence_score, :recruit_start_time, :recruit_end_time]

  attr_reader :errors, :campaign

  def initialize user, campaign_id, args={}
    @user                   = user
    @campaign               = Campaign.find_by_id campaign_id
    @update_campaign_params = permited_params_from args
    @errors                 = []
  end

  def perform
    if @update_campaign_params.empty? or @user.nil? or not @user.persisted? or @campaign.nil?
      @errors << 'Invalid params or user/campaign!'
      return false
    end

    if @campaign.user.id != @user.id
      @errors << 'No permission!'
      return false
    end

    if @campaign.status != "unexecute"
      @errors << "活动已经开始, 不能编辑"
      return false
    end

    origin_budget, budget, per_action_budget = @campaign.budget, @update_campaign_params[:budget], @update_campaign_params[:per_action_budget]
    if not enough_amount? @user, origin_budget, budget
      @errors << '账号余额不足, 请充值!'
      return false
    end

    format_to_db_time

    begin
      ActiveRecord::Base.transaction do
        update_recruit_region
        update_recruit_influnce_score
        @campaign.update_attributes(@update_campaign_params.reject {|k,v| [:influence_score, :region].include? k })
        @campaign.reset_campaign origin_budget, budget, per_action_budget
      end
    rescue Exception => e
      @errors.concat e.record.errors.full_messages.flatten
      return false
    end
  end

  def first_error_message
    @errors.first
  end

  private

  def format_to_db_time
    @update_campaign_params[:recruit_start_time] = @update_campaign_params[:recruit_start_time].to_formatted_s(:db)
    @update_campaign_params[:recruit_end_time] = @update_campaign_params[:recruit_end_time].to_formatted_s(:db)
    @update_campaign_params[:start_time] = @update_campaign_params[:start_time].to_formatted_s(:db)
    @update_campaign_params[:deadline] = @update_campaign_params[:deadline].to_formatted_s(:db)
  end

  def enough_amount? user, origin_budget, budget
    user.avail_amount.to_f + origin_budget.to_f >= budget.to_f
  end

  def permited_params_from params
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def update_recruit_region
    campaign_target = @campaign.campaign_targets.where(target_type: :region).first
    unless campaign_target.target_content.eql? @update_campaign_params[:region]
      campaign_target.update_attributes(target_content: @update_campaign_params[:region])
    end
  end

  def update_recruit_influnce_score
    campaign_target = @campaign.campaign_targets.where(target_type: :influence_score).first
    unless campaign_target.target_content.eql? @update_campaign_params[:influence_score]
      campaign_target.update_attributes(target_content: @update_campaign_params[:influence_score])
    end
  end

end
