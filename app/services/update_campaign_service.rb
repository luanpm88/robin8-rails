class UpdateCampaignService

  attr_reader :errors, :campaign

  def initialize user, campaign_id, args={}
    @user                   = user
    @campaign               = Campaign.find_by_id campaign_id
    @update_campaign_params = permited_params_from args
    
    @errors                 = []
  end

  def perform
    if @update_campaign_params.empty? or @user.nil? or not @user.persisted? or @campaign.nil? or not target_present?

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

    if is_cpa_campaign? and not any_action_url_present?
      @errors << 'No availiable action urls!'
      return false
    end

    origin_budget, budget, per_action_budget = @campaign.budget, @update_campaign_params[:budget], @update_campaign_params[:per_action_budget]
    if not enough_amount? @user, origin_budget, budget
      @errors << ["amount_not_engouh", '账号余额不足, 请充值!']
      return false
    end

    @update_campaign_params[:start_time] = @update_campaign_params[:start_time].to_formatted_s(:db)
    @update_campaign_params[:deadline] = @update_campaign_params[:deadline].to_formatted_s(:db)

    begin
      ActiveRecord::Base.transaction do

        update_campaign_action_urls
        update_campaign_targets

        @campaign.update_attributes(@update_campaign_params.reject {|c| [:campaign_action_url, :target].include? c })
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

  def enough_amount? user, origin_budget, budget
    user.avail_amount.to_f + origin_budget.to_f >= budget.to_f
  end

  def permited_params_from params
    params.nil? ? {} : params.select { |k,v| CreateCampaignService::PERMIT_PARAMS.include? k }
  end

  def is_cpa_campaign?
    @update_campaign_params[:per_budget_type].eql? 'cpa'
  end

  def any_action_url_present?
    @update_campaign_params[:campaign_action_url]
  end

  def target_present?
    @update_campaign_params[:target] and [:age, :region, :gender].all? {|k| @update_campaign_params[:target].keys.include? k }
  end

  def update_campaign_action_urls
    if campaign.per_budget_type == 'cpa' && @update_campaign_params[:per_budget_type] != 'cpa'
      campaign.campaign_action_urls.destroy_all and return
    end

    if (campaign_action_urls = @update_campaign_params[:campaign_action_url]) && @update_campaign_params[:per_budget_type] == 'cpa'
      @campaign.campaign_action_urls.destroy_all

      action_url = campaign_action_urls[:action_url]
      short_url = campaign_action_urls[:short_url]
      identifier = campaign_action_urls[:action_url_identifier]

      @campaign.campaign_action_urls.create!(action_url: action_url, short_url: short_url, identifier: identifier)
    end
  end

  def update_campaign_targets
    @campaign.campaign_targets.destroy_all

    @update_campaign_params[:target].each do |k,v|
      @campaign.campaign_targets.create!({target_type: k.to_s, target_content: v})
    end
  end

end
