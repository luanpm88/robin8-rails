module Campaigns
  module CampaignInviteAnalysis
    extend ActiveSupport::Concern

    def gender_analysis_of_invitee
      male_count   = self.kols.where(gender: 1).count
      female_count = self.kols.where(gender: 2).count
      total_count = male_count + female_count

      [
        {
          name: "男性",
          ratio: 1.0 * male_count / total_count
        },
        {
          name: "女性",
          ratio: 1.0 * female_count / total_count
        }
      ]
    end

    def age_analysis_of_invitee
      total_count = self.kols.where.not(age: nil).count

      [[0, 20], [20, 40], [40, 60], [60, 100]].map do |min, max|
        age_count = self.kols.where("age > ? AND age <= ?", min, max).count
        {
          name: "#{min}岁-#{max}岁",
          count: age_count,
          ratio: 1.0 * age_count / total_count
        }
      end
    end

    def tag_analysis_of_invitee
    end

    def city_analysis_of_invitee
    end

    def region_analysis_of_invitee
    end
  end
end