class CreateInviteCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :img_url, :budget, :per_budget_type,
                  :per_action_budget, :start_time, :deadline,:specified_kols]

  attr_reader :errors, :campaign

  def initialize user, args={}
    @user            = user
    @campaign_params = permitted_params_from args
    @errors          = []
  end

  def perform
    if @campaign_params.empty? or @user.nil? or not @user.persisted?
      # todo: use I18n(also include blow errors)
      @errors << 'Invalid params or user!'
      return false
    end

    specified_kols = @campaign_params.delete(:specified_kols)
    @campaign_params[:budget] = specified_kols.split(",").inject(0) do |sum, kol|
      sum += 100 # need sum by kol price
    end

    @campaign_params.merge!({:status => :unpay, :need_pay_amount => @campaign_params[:budget]})
    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)

    if @errors.size > 0
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create!(@campaign_params)
        @campaign.campaign_targets.create!({target_type: :specified_kols, target_content: specified_kols})
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

  def permitted_params_from params
    params.merge!(per_budget_type: 'invite')
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end
end