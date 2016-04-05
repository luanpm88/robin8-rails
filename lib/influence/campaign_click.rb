module Influence
  class CampaignClick
    def self.get_total_click_score(kol_id)
      article_count, read_count = ArticleAction.get_forward_info(kol_id)
      score = (12.5 * Math.log10(read_count)).round(0)
      score = 50  if score > 50
      score
    end

    def self.get_avg_click_score(kol_id)
      article_count, read_count = ArticleAction.get_forward_info(kol_id)
      avg_read_count = read_count / article_count
      score = (20 * Math.log10(avg_read_count)).round(0)
      score = 50  if score > 50
      score
    end
  end
end
