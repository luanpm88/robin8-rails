class CreateCampaignService
  PERMIT_PARAMS = [:name, :description, :url, :img_url, :budget, :per_budget_type, :per_action_budget, :start_time, :deadline, :message, :action_url_list]

  attr_reader :errors, :campaign

  def initialize user, args={}
    @user = user
    @campaign_params = permited_params_from args

    @errors = []
  end

  def perform

    if @campaign_params.empty? or @user.nil? or not @user.persisted?
      # todo: use I18n(also include blow errors)
      @errors << 'Invalid params or user!'
      return false
    end

    if not enough_amount?(@user, @campaign_params[:budget])
      @errors << 'Not enough amount!'
      return false
    end

    if is_cpa_campaign? and not any_action_url_present?
      @errors << 'No availiable action urls!'
      return false
    end

    @campaign_params.merge!({:status => :unexecute})

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create! @campaign_params.select{|k,v| k != :action_url_list}

        if is_cpa_campaign?
          @campaign_params[:action_url_list].each do |action_url|
            @campaign.campaign_action_urls.create!(action_url: action_url)
          end
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

  def permited_params_from params
    params.nil? ? [] : params.select { |k, v| PERMIT_PARAMS.include? k } 
  end

  def enough_amount? user, budget
    avail_amout = user.avail_amount
    avail_amout >= budget ? true : false
  end

  def is_cpa_campaign?
    @campaign_params[:per_budget_type].eql? 'cpa'
  end

  def any_action_url_present?
    @campaign_params[:action_url_list] and @campaign_params[:action_url_list].any?
  end

end
