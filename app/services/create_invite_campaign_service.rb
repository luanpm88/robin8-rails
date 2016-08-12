class CreateInviteCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :img_url, :budget, :per_budget_type,
                   :start_time, :deadline, :social_accounts, :material_ids]

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

    @campaign_params.merge!(per_budget_type: 'invite')
    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)
    @campaign_params[:social_accounts] = @campaign_params[:social_accounts].split(",").map(&:to_i) rescue []
    social_accounts = SocialAccount.where(id: @campaign_params[:social_accounts])

    @campaign_params[:budget] = social_accounts.inject(0) do |sum, social_account|
      sum += social_account.sale_price
    end unless social_accounts.blank?

    @campaign_params.merge!({:status => :unpay, :need_pay_amount => @campaign_params[:budget]})

    if @campaign_params[:budget] == 0
      @errors << 'campaign budget can not be zero!'
    end

    if @errors.size > 0
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        @campaign = @user.campaigns.create!(
          @campaign_params.reject { |k,v| [ :social_accounts, :material_ids ].include? k }
        )
        create_campaign_materials
        @campaign.social_account_targets.create!({
          target_type: :social_accounts,
          target_content: social_accounts.map(&:id).join(",")
        })
        social_accounts.each do |social_account|
          kol = social_account.kol
          kol.add_campaign_id @campaign.id
          kol.approve_and_receive_invite_campaign(@campaign.id, social_account.id)
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
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def create_campaign_materials
    return unless @campaign_params[:material_ids].present?
    CampaignMaterial.where(id: @campaign_params[:material_ids].split(",")).each do |campaign_material|
      campaign_material.update campaign_id: @campaign.id
    end
  end
end
