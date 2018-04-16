require 'csv'
#参考文档:https://developer.qiniu.com/kodo/sdk/1304/ruby
namespace :screenshot do 
  desc "Manually add screenshot to campaign_invites of Bayer from ali user"
  task :add => :environment do
    success = 0
    screenshots = []
    CSV.foreach("/home/deployer/bayer_screenshot.csv") do |row|
      screenshots << row[5][2..-3]
    end
    campaign_invites = CampaignInvite.joins(:kol, :campaign).where(screenshot: nil).where("campaigns.user_id = ? AND kols.channel = ?", 16344, 'azb').first(1477)
    campaign_invites.each_with_index do |ci, index|
      url = screenshots[index+1]
      bucket = 'robin8'
      web_content = open(url) {|f| f.read}
      key = "ci_#{ci.id}.jpg"
      file_path = '/home/deployer/azb/' + key
      file = File.open(file_path, 'wb'){|f| f.write(web_content)}
      put_policy = Qiniu::Auth::PutPolicy.new(bucket, key, 3600)
      uptoken = Qiniu::Auth.generate_uptoken(put_policy)
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(uptoken, file_path, key, nil, bucket: bucket)
      if code == 200
        ci.screenshot = "http://7xozqe.com2.z0.glb.clouddn.com/#{key}"
        ci.save
        success += 1
      else
        CSV.open('public/failed.csv', 'w') do |csv|  
          csv << url
        end 
      end
      puts success
    end
  end
end
