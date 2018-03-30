class UpdateInviteCampaignService
  include CampaignHelper::RecruitCampaignServicePartial

  PERMIT_PARAMS = [:name, :description, :img_url, :budget, :per_budget_type,
                   :start_time, :deadline, :social_accounts, :material_ids]

  attr_reader :errors, :campaign

  def initialize user, campaign_id, args={}
    @user                   = user
    @campaign               = Campaign.where(per_budget_type: "invite", id: campaign_id).first
    @campaign_params        = permitted_params_from args
    @errors                 = []
  end

  def perform
    if @campaign_params.empty? or @user.nil? or not @user.persisted? or @campaign.nil?
      @errors << 'Invalid params or user/campaign!'
      return false
    end

    if @campaign.status == "rejected"
      @campaign_params.merge!(:status => "unexecute", :invalid_reasons => nil)
    end

    if @campaign.user.id != @user.id
      @errors << 'No permission!'
      return false
    end

    unless can_edit?
      @errors << "活动已经开始, 不能编辑!"
      return false
    end

    @campaign_params[:start_time] = @campaign_params[:start_time].to_formatted_s(:db)
    @campaign_params[:deadline] = @campaign_params[:deadline].to_formatted_s(:db)
    @campaign_params[:social_accounts] = @campaign_params[:social_accounts].split(",").map(&:to_i) rescue []
    social_accounts = SocialAccount.where(id: @campaign_params[:social_accounts])

    @campaign_params[:budget] = social_accounts.inject(0) do |sum, social_account|
      sum += social_account.sale_price
    end unless social_accounts.blank?

    # @campaign_params.merge!({:need_pay_amount => @campaign_params[:budget]})

    # if @campaign_params[:budget] == 0
    #   @errors << 'campaign budget can not be zero!'
    # end

    if @errors.size > 0
      return false
    end

    begin
      ActiveRecord::Base.transaction do
        campaign_target = @campaign.social_account_targets.first
        campaign_target.update!(target_content: social_accounts.map(&:id).join(","))

        update_materials
        @campaign.update(@campaign_params.reject {|k,v| [:social_accounts, :material_ids].include? k })

        @campaign.campaign_invites.each do |campaign_invite|
          kol = campaign_invite.kol
          kol.delete_campaign_id @campaign.id
          campaign_invite.destroy
        end

        social_accounts.each do |social_account|
          kol = social_account.kol
          kol.add_campaign_id @campaign.id
          kol.approve_and_receive_invite_campaign(@campaign.id, social_account.id)
        end
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

  def permitted_params_from params
    params.select { |k, v| PERMIT_PARAMS.include? k }
  end

  def delete_all_materials
    @campaign.campaign_materials.delete_all
  end

  def update_materials
    return delete_all_materials unless @campaign_params[:material_ids].present?
    existed_materials = []
    new_materials = []
    @campaign_params[:material_ids].split(",").each do |id|
      if campaign_material = @campaign.campaign_materials.where(id: id).take
        existed_materials << campaign_material
      else
        campaign_material =  CampaignMaterial.where(id: id).take
        campaign_material.update(campaign_id: @campaign.id)
        new_materials << campaign_material
      end
    end
    (@campaign.campaign_materials - new_materials - existed_materials).each { |x| x.delete}
  end

  def can_edit?
    ['unpay', 'unexecute', 'rejected', 'agreed'].include?(@campaign.status) ? true : false
  end

end
