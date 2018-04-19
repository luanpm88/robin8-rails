class KolCreateCampaignService
  include CampaignHelper::RecruitCampaignServicePartial
  PERMIT_PARAMS = [:name, :description, :url, :img_url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline,
                   :message, :campaign_action_url, :age, :region, :gender, :tags, :need_pay_amount, :campaign_from, :example_screenshot,
                   :sub_type, :enable_append_push, :activity_id]

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


    # if not enough_amount?(@user, @campaign_params[:budget])
    #   @errors << ["amount_not_engouh", '账号余额不足, 请充值!']
    #   return false
    # end


    if is_cpa_campaign? and not any_action_url_present?
      @errors << 'No availiable action urls!'
      return false
    end

    @campaign_params.merge!({:status => :unpay})
    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)

    if @errors.size > 0
      return false
    end
    begin
      @campaign = @user.campaigns.create! @campaign_params.reject{|k,v| [:campaign_action_url, :age, :region, :gender, :tags].include? k }
      create_default_targets
      return true
    rescue Exception => e
      @errors.concat e.record.errors.messages.map(&:last).flatten
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

  def create_default_targets
    ['age', 'region', 'gender'].each do |target_type|
      @campaign.campaign_targets.create!({target_type: target_type, target_content: @campaign_params[target_type.to_sym]})
    end

    tag_labels = @campaign_params[:tags]
    @campaign.campaign_targets.create!({target_type: 'tags', target_content: tag_labels.split(',').collect { |label| ::Tag.get_name_by_label(label) }.join(',')})
  end

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
