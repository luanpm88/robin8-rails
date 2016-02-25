class CampaignActionUrl < ActiveRecord::Base
  belongs_to :campaign
  after_save :save_short_url

  def save_short_url
    uuid = Base64.encode64({ :campaign_id => self.campaign.id, :campaign_action_url_id => self.id, :step => '2' }.to_json).gsub("\n","")
    self.short_url = generate_short_url(uuid)
    self.update_column(:short_url, self.short_url)
  end

  def generate_short_url(uuid)
    ShortUrl.convert(origin_action_url(uuid))
  end


  def origin_action_url(uuid)
    "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"          rescue nil
  end


end
