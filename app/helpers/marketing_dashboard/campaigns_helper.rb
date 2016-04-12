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
end
