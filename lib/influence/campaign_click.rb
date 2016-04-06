module Influence
  class CampaignClick
    def self.get_total_click_score(kol_id)
      invite_count, real_click_count = CampaignInvite.get_click_info(kol_id)
      score = (16.5 * Math.log10(real_click_count)).round(0)
      score = 50  if score > 50
      score
    end

    def self.get_avg_click_score(kol_id)
      invite_count, real_click_count = CampaignInvite.get_click_info(kol_id)
      avg_click_count = real_click_count / invite_count
      score = (25 * Math.log10(avg_click_count)).round(0)
      score = 50  if score > 50
      score
    end
  end
end
