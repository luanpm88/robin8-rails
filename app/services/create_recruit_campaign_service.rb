class CreateRecruitCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :img_url, :budget, :per_budget_type,
                  :per_action_budget, :start_time, :deadline,
                  :region, :tags, :sns_platforms, :recruit_start_time, :url, :sub_type,
                  :recruit_end_time, :hide_brand_name, :material_ids ]

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

    if @campaign_params[:sub_type].blank? or @campaign_params[:sub_type] == "null"
      @campaign_params[:sub_type] = nil
    end

    validate_recruit_time
    @campaign_params.merge!({:status => :unpay, :need_pay_amount => @campaign_params[:budget]})

    if @errors.size > 0
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create!(@campaign_params.reject{|k,v| [:region, :tags, :sns_platforms, :material_ids].include? k })

        create_campaign_materials

        @campaign_params.select{ |k, v| [:region, :tags, :sns_platforms].include? k }.each do |k, v|
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
    # params.merge!(address: nil) if (params[:address] == 'undefined' or !params.present?)
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def create_campaign_materials
    return unless @campaign_params[:material_ids].present?
    CampaignMaterial.where(id: @campaign_params[:material_ids].split(",")).each do |campaign_material|
      campaign_material.update campaign_id: @campaign.id
    end
  end

  # def enough_amount? user, budget
  #   avail_amout = user.avail_amount
  #   avail_amout >= budget ? true : false
  # end
end
