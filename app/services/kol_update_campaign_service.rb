class KolUpdateCampaignService
  attr_reader :errors, :campaign

  def initialize user, campaign, args={}
    @user                   = user
    @campaign               = campaign
    @campaign_params = permited_params_from args

    @errors                 = []
  end

  def perform
    if @campaign_params.empty? or @user.nil? or not @user.persisted? or @campaign.nil?

      @errors << 'Invalid params or user/campaign!'
      return false
    end

    if @campaign.user.id != @user.id
      @errors << 'No permission!'
      return false
    end

    unless %w(unpay unexecute rejected).include? @campaign.status
      @errors << "活动已经开始, 不能编辑"
      return false
    end

    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)

    if @errors.size > 0
      return false
    end
    begin
      ActiveRecord::Base.transaction do
        @campaign.update_attributes @campaign_params.reject{|k,v| [:campaign_action_url, :age, :region, :gender, :tags].include? k }
        update_campaign_targets
      end
    rescue Exception => e
      @errors.concat e.record.errors.messages.map(&:last).flatten
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

  def permited_params_from params
    params.nil? ? {} : params.select { |k,v| KolCreateCampaignService::PERMIT_PARAMS.include? k }
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

  def update_campaign_action_urls
    if campaign.per_budget_type == 'cpa'  && @campaign_params[:per_budget_type] != 'cpa'
      campaign.campaign_action_urls.destroy_all and return
    end

    if (campaign_action_urls = @campaign_params[:campaign_action_url]) && @campaign_params[:per_budget_type] == 'cpa'
      @campaign.campaign_action_urls.destroy_all

      action_url = campaign_action_urls[:action_url]
      short_url = campaign_action_urls[:short_url]
      identifier = campaign_action_urls[:action_url_identifier]

      @campaign.campaign_action_urls.create!(action_url: action_url, short_url: short_url, identifier: identifier)
    end
  end

  def update_campaign_targets
    @campaign.campaign_targets.destroy_all

    ['age', 'region', 'gender', 'tags'].each do |target_type|
      @campaign.campaign_targets.create!({target_type: target_type, target_content: @campaign_params[target_type.to_sym]})
    end
  end

end
