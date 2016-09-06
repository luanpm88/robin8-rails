module MarketingDashboard::CampaignsHelper
  def filter_kol_reason kol_id, remove_kol_ids, black_list_ids, receive_campaign_kol_ids, today_receive_three_times_kol_ids
    reasons = []
    if remove_kol_ids.include?(kol_id)
      reasons << "指定去掉该kol"
    end
    if black_list_ids.include?(kol_id)
      reasons << "在黑名单中"
    end

    if receive_campaign_kol_ids.include?(kol_id)
      reasons << "接过了你指定的campaign"
    end

    if today_receive_three_times_kol_ids.include?(kol_id)
      reasons << "今天接过了3次campaign"
    end
    reasons.join("、")
  end

  def get_brand_campaign_show_url campaign
    if campaign.per_budget_type == "recruit"
      "/brand/recruits/#{campaign.id}?super_visitor_token=#{get_super_visitor_token}&user_id=#{campaign.user_id}"
    elsif campaign.per_budget_type == "invite"
      "/brand/invites/#{campaign.id}?super_visitor_token=#{get_super_visitor_token}&user_id=#{campaign.user_id}"
    else
      "/brand/campaigns/#{campaign.id}?super_visitor_token=#{get_super_visitor_token}&user_id=#{campaign.user_id}"
    end
  end

  def get_edit_brand_campaign_show_url c
    if c.per_budget_type == "recruit"
      "/brand/recruits/#{c.id}/edit?super_visitor_token=#{get_super_visitor_token}&user_id=#{c.user_id}"
    elsif c.per_budget_type == "invite"
      "/brand/invites/#{c.id}/edit?super_visitor_token=#{get_super_visitor_token}&user_id=#{c.user_id}"
    else
      "/brand/campaigns/#{c.id}/edit?super_visitor_token=#{get_super_visitor_token}&user_id=#{c.user_id}"
    end
  end

  def get_campaign_seller(c)
    if c.seller_invite_code.present?
      Crm::Seller.find_by(invite_code: c.seller_invite_code)
    else
      alipay_order = c.user.alipay_orders.where.not(invite_code: nil).take
      Crm::Seller.find_by(invite_code: alipay_order.invite_code) if alipay_order
    end
  end
end
