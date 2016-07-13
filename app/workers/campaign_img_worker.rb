class CampaignImgWorker
  include Sidekiq::Worker

  def perform(campaign_id, img_url)
    begin
      file_name = URI(img_url).path.downcase[1..-1]
      if file_name.end_with?("png")
        local_path = "#{Rails.root}/public/assets/#{file_name}"
        system("wget #{img_url} -O #{local_path}")
        if(File.size?(local_path))
          coverted_image = MiniMagick::Image.open(local_path)
          coverted_image.format "jpg"
          image = Image.new
          image.avatar = coverted_image
          image.save
          Campaign.find(campaign_id).update_column(:img_url, image.avatar_url)
        end
      end
    rescue Exception => e
    end
  end
end