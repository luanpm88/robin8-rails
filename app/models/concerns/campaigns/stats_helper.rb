module Campaigns
  module StatsHelper
    extend ActiveSupport::Concern
    def get_platforms_for_cpi
      platforms = self.campaign_shows.where(:status => "1").map(&:app_platform)
      [platforms.count("IOS"), platforms.count("Android")]
    end
  end
end
