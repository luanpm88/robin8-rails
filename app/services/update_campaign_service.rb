class UpdateCampaignService

  attr_reader :errors, :campaign

  def initialize user, campaign_id, args={}
    @user = user
    @campaign = Campaign.find_by_id campaign_id
    @update_campaign_params = permited_params_from args
    
    @errors = []
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

    if is_cpa_campaign? and not any_action_url_present?
      @errors << 'No availiable action urls!'
      return false
    end

    origin_budget, budget, per_action_budget = @campaign.budget, @update_campaign_params[:budget], @update_campaign_params[:per_action_budget]
    if not enough_amount? @user, origin_budget, budget
      @errors << 'Not enough amount!'
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        
        if campaign_action_urls = @update_campaign_params[:action_url_list]
          @campaign.campaign_action_urls.destroy_all

          campaign_action_urls.each do |action_url|
            @campaign.campaign_action_urls.create!(action_url: action_url)
          end
        end
        
        @campaign.update_attributes(@update_campaign_params.tap {|c| c.delete :action_url_list})
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
    @update_campaign_params[:action_url_list] and @update_campaign_params[:action_url_list].any?
  end

end
