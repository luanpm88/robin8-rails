module Jd
  class Settle
    SettleInterval = 28.days
    ArticleTax = 0.1
    PlatformTax = 0.3
    def self.schedule_settle
      should_settle_time = (Time.now - SettleInterval).strftime("%Y%m%d%H")
      CpsPromotionOrder.where("receipt_query_time <= '#{should_settle_time}'").where(:status => ['finished', 'return_part']).each do |order|
         order.with_lock do
           next if ['settled', 'canceled', 'full_return'].include?(order.status) || order.commision_fee.blank? ||  order.commision_fee == 0
           # 文章分享者  佣金
           order.kol.income(order.commision_fee * (1 -  ArticleTax - PlatformTax), 'cps_share_commission', order)
           # 文章创作者 佣金
           order.cps_article_share.get_article_author.income(order.commision_fee * ArticleTax, 'cps_writing_commission', order)
           # 系统佣金
           User.get_platform_account.income(order.commision_fee * PlatformTax, 'cps_tax', order)
           # 更改系统登记
           order.status = 'settled'
           order.save!
        end
      end
    end
  end
end
