module Kols
  module StatisticHelper
    extend ActiveSupport::Concern

    def get_income_of(item)
      if item.present? and item.respond_to? :get_net_income
        return item.get_net_income(self)
      end
    end

    # 总的净收入金额，赚得钱减去成本
    def total_income
      self.historical_income
    end

    # 总的取现成功的金额
    def total_withdraw
      self.withdraw_transactions.sum(:credits)
    end

    def maximum_click_of_campaigns
      self.campaign_invites.maximum(:avail_click)
    end

    def average_click_of_campaigns
      self.campaign_invites.average(:avail_click).to_f
    end
  end
end