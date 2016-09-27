class CampaignPushRecordWorker
  include Sidekiq::Worker

  def perform(campaign_id, push_type = 'normal')
    campaign = Campaign.find(campaign_id) rescue nil

    #TODO 可以合并到现有流程中
    # if campaign.is_invite_type?                        #特邀活动
    #   kol_ids = campaign.get_social_account_related_kol_ids
    #   CampaignPushRecord.create(campaign_id: campaign_id, kol_ids: kol_ids.join(","),  push_type: push_type, filter_type: 'match', filter_reason: 'invite')
    # elsif campaign.specified_kol_targets.present?       #指定任务
    #   kol_ids = campaign.get_ids_from_target_content campaign.specified_kol_targets.map(&:target_content)
    #   CampaignPushRecord.create(campaign_id: campaign_id, kol_ids: kol_ids.join(","), push_type: push_type, filter_type: 'match', filter_reason: 'specified_kol')
    # elsif campaign.newbie_kol_target.present?          #新手活动
    #   CampaignPushRecord.create(campaign_id: campaign_id, kol_ids: "", push_type: push_type, filter_type: 'match', filter_reason: 'newbie_kol')
    #   return []
    # else
    #   if push_type == 'normal'
    #     unmatched_kol_ids = campaign.get_unmatched_kol_ids
    #     kol_ids = campaign.get_matching_kol_ids -  unmatched_kol_ids
    #     CampaignPushRecord.create(campaign_id: campaign_id, kol_ids: unmatched_kol_ids.join(","), push_type: push_type, filter_type: 'unmatch', filter_reason: 'unmatch')
    #     CampaignPushRecord.create(campaign_id: campaign_id, kol_ids: kol_ids.join(","), push_type: push_type, filter_type: 'match', filter_reason: 'match')
    #   elsif push_type == 'append'
    #     unmatched_kol_ids = campaign.get_unmatched_kol_ids
    #     kol_ids = get_matching_kol_ids -  unmatched_kol_ids
    #   elsif push_type == 'push_all'
    #   end
    # end
  end

end
