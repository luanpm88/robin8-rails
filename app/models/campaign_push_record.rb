class CampaignPushRecord < ActiveRecord::Base
  belongs_to :campaign

  def kols
    Kol.where(id: self.kol_ids.split(","))
  end

  def converted_target_type
    m = /(?=(.*)_target_removed)/.match(self.filter_reason)
    m[1] rescue nil
  end

  def self.restrict_to_time_range(t)
    t = (Time.now + t)
    h = t.hour

    if (0..8).include?(h)
      t = (t.to_date + 9.hours).to_time + Random.rand(60).minutes
    elsif (22..23).include?(h)
      t = (t.tomorrow.to_date + 9.hours).to_time + Random.rand(60).minutes
    end
    t
  end
end
