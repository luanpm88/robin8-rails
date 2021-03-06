module MarketingDashboard::CampaignsHelper
  def filter_kol_reason kol_id, remove_kol_ids, black_list_ids, receive_campaign_kol_ids, three_hours_had_receive_kol_ids
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

    if three_hours_had_receive_kol_ids.include? kol_id
      reasons << "3小时内接过活动"
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

  def get_base_edit_brand_campaign_show_url c
    "/brand/campaigns/#{c.id}/edit_base?super_visitor_token=#{get_super_visitor_token}&user_id=#{c.user_id}"
  end

  def get_campaign_seller(c)
    c.user.seller
  end
end
