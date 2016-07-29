class CreateRecruitCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :task_description,
                  :address, :img_url, :budget, :per_budget_type,
                  :per_action_budget, :start_time, :deadline,
                  :region, :influence_score, :recruit_start_time,
                  :recruit_end_time, :hide_brand_name, :materials]

  attr_reader :errors, :campaign

  def initialize user, args={}
    @user            = user
    @campaign_params = permitted_params_from args
    @errors          = []
  end

  def perform
    format_to_db_time

    if @campaign_params.empty? or @user.nil? or not @user.persisted?
      # todo: use I18n(also include blow errors)
      @errors << 'Invalid params or user!'
      return false
    end

    # if not enough_amount?(@user, @campaign_params[:budget])
    #   @errors << ["amount_not_engouh", '账号余额不足, 请充值!']
    #   return false
    # end

    validate_recruit_time
    @campaign_params.merge!({:status => :unpay, :need_pay_amount => @campaign_params[:budget]})

    if @errors.size > 0
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create!(@campaign_params.reject{|k,v| [:region, :influence_score, :materials].include? k })

        create_campaign_materials

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

  def permitted_params_from params
    params.merge!(per_budget_type: 'recruit')
    params.merge!(address: nil) if (params[:address] == 'undefined' or !params.present?)
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def create_campaign_materials
    return unless @campaign_params[:materials].present?
    eval(@campaign_params[:materials]).each do |material|
      @campaign.campaign_materials.create(url_type: material.first, url: material.last)
    end
  end

  # def enough_amount? user, budget
  #   avail_amout = user.avail_amount
  #   avail_amout >= budget ? true : false
  # end
end
