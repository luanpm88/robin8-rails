class CreateRecruitCampaignService
  PERMIT_PARAMS = [:name, :description, :task_description, :url, :img_url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :region, :influence_score, :recruit_start_time, :recruit_end_time]

  attr_reader :errors, :campaign

  def initialize user, args={}
    @user            = user
    @campaign_params = permited_params_from args
    @errors          = []
  end

  def perform
    if @campaign_params.empty? or @user.nil? or not @user.persisted?
      # todo: use I18n(also include blow errors)
      @errors << 'Invalid params or user!'
      return false
    end

    if not enough_amount?(@user, @campaign_params[:budget])
      @errors << '账号余额不足, 请充值!'
      return false
    end

    @campaign_params.merge!({:status => :unexecute})

    format_to_db_time

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create!(@campaign_params.reject{|k,v| [:region, :influence_score].include? k })

        @campaign_params.select{ |k, v| [:region, :influence_score].include? k }.each do |k, v|
          @campaign.campaign_targets.create!({target_type: k.to_s, target_content: v})
        end
      end
      return true
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
    @campaign_params[:recruit_start_time] = @campaign_params[:recruit_start_time].to_formatted_s(:db)
    @campaign_params[:recruit_end_time] = @campaign_params[:recruit_end_time].to_formatted_s(:db)
    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)
  end

  def permited_params_from params
    params.merge!(per_budget_type: 'recruit')
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def enough_amount? user, budget
    avail_amout = user.avail_amount
    avail_amout >= budget ? true : false
  end

end
