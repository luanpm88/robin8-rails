class UpdateRecruitCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :task_description,
                   :address, :img_url, :budget, :per_budget_type,
                  :per_action_budget, :start_time, :deadline,
                  :region, :influence_score, :recruit_start_time, :recruit_end_time, :hide_brand_name]

  attr_reader :errors, :campaign

  def initialize user, campaign_id, args={}
    @user                   = user
    @campaign               = Campaign.find_by_id campaign_id
    @campaign_params = permitted_params_from args
    @errors                 = []
  end

  def perform
    format_to_db_time

    if @campaign_params.empty? or @user.nil? or not @user.persisted? or @campaign.nil?
      @errors << 'Invalid params or user/campaign!'
      return false
    end

    if @campaign.status == "rejected"
      @campaign_params.merge!(:status => "unexecute", :invalid_reasons => nil)
    end

    if @campaign.user.id != @user.id
      @errors << 'No permission!'
      return false
    end

    unless can_edit?
      @errors << "活动已经开始, 不能编辑!"
      return false
    end

    validate_recruit_time
    unless can_edit_budget?
      @errors << "活动已提交, 招募人数或者人均奖励不能更改!"
    end

    if @errors.size > 0
      return false
    end


    begin
      ActiveRecord::Base.transaction do
        update_recruit_region
        update_recruit_influnce_score
        @campaign.update_attributes(@campaign_params.reject {|k,v| [:influence_score, :region].include? k })
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

  def enough_amount? user, origin_budget, budget
    user.avail_amount.to_f + origin_budget.to_f >= budget.to_f
  end

  def permitted_params_from params
    params.merge!(address: nil) unless params[:address].present?
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def update_recruit_region
    campaign_target = @campaign.campaign_targets.where(target_type: :region).first
    unless campaign_target.target_content.eql? @campaign_params[:region]
      campaign_target.update_attributes(target_content: @campaign_params[:region])
    end
  end

  def update_recruit_influnce_score
    campaign_target = @campaign.campaign_targets.where(target_type: :influence_score).first
    unless campaign_target.target_content.eql? @campaign_params[:influence_score]
      campaign_target.update_attributes(target_content: @campaign_params[:influence_score])
    end
  end

  def can_edit?
    ['unpay', 'unexecute', 'rejected'].include?(@campaign.status) ? true : false
  end

  def can_edit_budget?
    @campaign.budget_editable
  end

end
