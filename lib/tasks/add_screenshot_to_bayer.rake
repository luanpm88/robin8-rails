require 'csv'
namespace :screenshot do 
  desc "Manually add screenshot to campaign_invites of Bayer from ali user"
  task :add => :environment do
    success = 0
    failed_records = []
    screenshots = []
    CSV.foreach("/home/deployer/bayer_screenshot.csv") do |row|
      screenshots << row[5][2..-3]
    end
    campaign_invites = CampaignInvite.joins(:kol, :campaign).where("campaigns.user_id = ? AND kols.channle = ?", 16344, 'azb').first(9344)
    campaign_invites.each_with_index do |ci, index|
      ci.screenshot = screenshots[index+1]
      if ci.save 
        success += 1
      else 
        failed_records << [ci, index]
      end
    end
    puts "总共加入#{success}个,失败#{failed_records.size}个"
  end
end
