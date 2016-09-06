class CampaignMaterial < ActiveRecord::Base
  belongs_to :campaign

  def self.get_track_url(material, kol_id)
    invite = CampaignInvite.where(:campaign_id => material.campaign_id, :kol_id => kol_id).first  rescue nil
    return material.url   if  invite.blank?
    if material.url_type == 'article' || material.url_type == 'video'
      uuid = Base64.encode64({:material_url => material.url, :campaign_invite_id => invite.id}.to_json).gsub("\n","")
      return "#{Rails.application.secrets.domain}/commons/material?uuid=#{uuid}"
    end
    return material.url
  end
end
