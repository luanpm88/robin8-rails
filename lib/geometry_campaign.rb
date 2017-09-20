require 'roo'
require 'csv'
geometry_campaign = File.new("#{Rails.root}/public/campaign.txt","w+")
ids = []
Admintag.find_by(tag: "geometry").kols.distinct.each do |t|
  ids.push(t.id)
end
campaign_id = [4086,4091]
# ids = Admintag.joins(:kols).where(tag: "geometry").map{|t| t.kols[0]["id"]}
CampaignInvite.where(campaign_id: campaign_id , kol_id: ids).each do |t|
  if t.status != "passed"
  	t.status = "passed" 
    t.save
  end
  detail = "#{t.kol_id}@#{t.kol.mobile_number}@#{t.campaign_id}@#{t.campaign.name}@#{t.status}"
  geometry_campaign.write("#{detail}&")
end
geometry_campaign.close