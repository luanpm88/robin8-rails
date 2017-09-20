require 'roo'
require 'csv'
geometry_campaign = File.new("#{Rails.root}/public/campaign.txt","w+")
ids = []
Admintag.find(425).kols.distinct.each do |t|
  ids.push(t.id)
end
campaign_id = [4086,4091]
# ids = Admintag.joins(:kols).where(tag: "geometry").map{|t| t.kols[0]["id"]}
CampaignInvite.where(campaign_id: campaign_id , kol_id: ids).each do |t|
  detail = "#{t.kol_id}@#{t.campaign_id}@#{t.campaign.name}@#{t.status}"
  geometry_campaign.write("#{detail}&")
end
geometry_campaign.close