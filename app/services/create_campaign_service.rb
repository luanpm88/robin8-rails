class CreateCampaignService
  PERMIT_PARAMS = [:name, :description, :url, :img_url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :message, :campaign_action_url, :target]

  attr_reader :errors, :campaign

  def initialize user, args={}
    @user            = user
    @campaign_params = permited_params_from args

    @errors          = []
  end

  def perform
    if @campaign_params.empty? or @user.nil? or not @user.persisted? or not target_present?
      # todo: use I18n(also include blow errors)
      @errors << 'Invalid params or user!'
      return false
    end

    validate_recruit_time

    if not enough_amount?(@user, @campaign_params[:budget])
      @errors << '账号余额不足, 请充值!'
      return false
    end

    if is_cpa_campaign? and not any_action_url_present?
      @errors << 'No availiable action urls!'
      return false
    end

    if @errors.size > 0
      return false
    end

    @campaign_params.merge!({:status => :unexecute})
    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create! @campaign_params.reject{|k,v| [:campaign_action_url, :target].include? k }

        if is_cpa_campaign?
          action_url = @campaign_params[:campaign_action_url][:action_url]
          short_url = @campaign_params[:campaign_action_url][:short_url]
          identifier = @campaign_params[:campaign_action_url][:action_url_identifier]
          @campaign.campaign_action_urls.create!(action_url: action_url, short_url: short_url, identifier: identifier)
        end

        @campaign_params[:target].each do |k,v|
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

  def permited_params_from params
    params.nil? ? {} : params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  private

  def enough_amount? user, budget
    avail_amout = user.avail_amount
    avail_amout >= budget ? true : false
  end

  def is_cpa_campaign?
    @campaign_params[:per_budget_type].eql? 'cpa'
  end

  def any_action_url_present?
    @campaign_params[:campaign_action_url]
  end

  def target_present?
    @campaign_params[:target] and [:age, :region, :gender].all? {|k| @campaign_params[:target].keys.include? k }
  end

end
