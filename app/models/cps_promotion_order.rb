class CpsPromotionOrder < ActiveRecord::Base
  has_many :cps_promotion_order_items
  belongs_to :kol
  belongs_to :cps_article_share
  has_one :cps_article, :through => :cps_article_share

  # after_save :update_status

  def update_status
    if self.previous_changes["yn"] ||  self.previous_changes["cos_price"]
      if self.previous_changes["yn"][0].blank? && self.previous_changes["cos_price"][0].blank?
        self.update_column(:status, 'pending')
      elsif self.previous_changes["cos_price"] &&  self.previous_changes["cos_price"][0] > 0 && self.previous_changes["cos_price"][1] == 0
        ''
      end

    end
  end

  #1. 检查更新: 每隔15分钟同步一次订单.同步传入的时间为当前小时 和上小时

  #2. 更新历史:每天同步一次最近7天的历史yn=1订单.更改订单的yn 状态 .传入时间,需计算

  #3. 检查更新: 每隔15分钟,同步一次业绩订单,更新 完成查询时间, 和

  #4. 更新历史

end
