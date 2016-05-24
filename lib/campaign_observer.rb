module CampaignObserver
  extend self
  MaxTotalClickCount = 100
  MaxValidClickCount = 30

  def observer_campaign_and_kol campaign_id, kol_id
    invalid_reasons = []

    shows = CampaignShow.where(:campaign_id => campaign_id, :kol_id => kol_id).order("created_at asc")

    if shows.count > MaxTotalClickCount
      invalid_reasons << "总点击量大于#{MaxTotalClickCount}"
    end

    if shows.where(:status => "1").count > MaxValidClickCount
      invalid_reasons << "有效点击量大于#{MaxValidClickCount}"
    end

    shows.each do |show|
      
    end
  end
end