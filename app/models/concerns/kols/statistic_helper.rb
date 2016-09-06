module Kols
  module StatisticHelper
    extend ActiveSupport::Concern

    def total_income
      self.income_transactions.sum(:credits)
    end

    def total_withdraw
      self.withdraw_transactions.sum(:credits)
    end

    def maximum_click_of_campaigns
      self.campaign_invites.maximum(:avail_click)
    end

    def average_click_of_campaigns
      self.campaign_invites.average(:avail_click)
    end
  end
end