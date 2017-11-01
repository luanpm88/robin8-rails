require 'roo'
begin
	xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/campaign.xlsx")
	ids = xlsx.column(1)
	# geometry_campaign = File.new("#{Rails.root}/public/campaign.txt","w+")
	# ids = []
	# Admintag.find_by(tag: "geometry").kols.distinct.each do |t|
	  # ids.push(t.id)
	# end

	detail = ''
	ids = Admintag.find_by(tag: "geometry").kols.distinct.map {|t| t.id}
	campaign_id = [4086,4091]
	CampaignInvite.where(campaign_id: campaign_id , kol_id: ids).each do |t|
	  if t.img_status != "passed"
	  	t.img_status = "passed" 
	    t.save
	  end
	  # t.kol.amount = t.kol.amount - t.campaign.per_action_budget
	  # t.kol.save
	  unless ids.include?(t.kol_id)
	    t.kol.amount = t.kol.amount - t.campaign.per_action_budget
	    t.kol.save
	  end


	  detail = "#{t.kol_id}@#{t.kol.mobile_number}@#{t.campaign_id}@#{t.total_click}@#{t.avail_click}&" + detail
	  # geometry_campaign.write("#{detail}&")
	end
	puts detail
	# geometry_campaign.close
rescue
    puts "出错,请重试"
end
