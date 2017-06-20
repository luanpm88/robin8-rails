namespace :fix_clicks do
  task :openid => :environment do
    bad_records = CampaignShow.where('created_at > ?', DateTime.now - 2.days).where(remark: 'had_no_openid').where(campaign_id: [3513, 3509])
    #.where(campaign_id: [3516, 3511, 3510])
    puts "Number of all records to fix: #{bad_records.size}"

    bad_records.each do |campaign_show|
      # puts "----"
      campaign_show.status = '1'
      campaign_show.remark = nil
      campaign_show.save(:validate => false)

      campaign = Campaign.find(campaign_show.campaign_id)
      campaign.add_click(true)
      # puts "Campaign ID: #{campaign.id}"

      campaign_invites = CampaignInvite.where(kol_id: campaign_show.kol_id, campaign_id: campaign.id)
      # puts "Number of campaign_invites #{campaign_invites.size}"

      campaign_invite = campaign_invites.first
      # puts "CampaignInvite ID: #{campaign_invite.id}"
      # puts "Invite get_total_click: #{campaign_invite.get_total_click} | get_avail_click: #{campaign_invite.get_avail_click}"
      campaign_invite.add_click(true)
      # puts "Invite get_total_click: #{campaign_invite.get_total_click} | get_avail_click: #{campaign_invite.get_avail_click}"
    end
  end
end
