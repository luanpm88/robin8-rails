class CampaignPushRecord < ActiveRecord::Base
  belongs_to :campaign

  def kols
    Kol.where(id: self.kol_ids.split(","))
  end

  def converted_target_type
    m = /(?=(.*)_target_removed)/.match(self.filter_reason)
    m[1] rescue nil
  end
end
