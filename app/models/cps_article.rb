class CpsArticle < ActiveRecord::Base
  include Redis::Objects
  has_many :cps_article_materials
  has_many :cps_article_shares
  belongs_to :author, :foreign_key => :kol_id, :class_name => 'Kol'
  belongs_to :kol
  has_many :cps_materials, :through => :cps_article_materials
  counter :read_count

  before_save :build_article_materials
  after_save :send_notify_to_author

  # status  pending, passed, rejected
  scope :enabled, -> {where(:enabled => true)}
  scope :pending, -> {where(:status => 'pending')}
  scope :passed, -> {where(:status => 'passed')}
  scope :rejected, -> {where(:status => 'rejected')}

  Statuses = {'pending' => '待审核', 'passed' => '审核通过', 'rejected' => '审核拒绝'}

  def show_url
    "#{Rails.application.secrets.domain}/cps_articles/#{self.id}"
  end

  def content_arr
    self.content.split(/(<text>)|(<img>)|(<product>)/)[1..-1]       rescue []
  end

  def build_article_materials
    arr = self.content.split(/(<product>)/)
    index = 0
    product_ids = []
    while index < arr.length
      if arr[index] == "<product>"
        product_ids <<  arr[index + 1]
        index = index + 2
      else
        index = index + 1
      end
    end
    self.cps_material_ids = product_ids
  end

  def material_total_price
    Rails.cache.fetch("cps_article_material_totle_price_#{self.id}") do
      self.cps_materials.sum(:kol_commision_wl).round(2)
    end
  end

  # 获取文章写作 预计佣金
  def writing_forecast_commission
    commission = self.cps_article_shares.collect{|t| t.cps_promotion_valid_order_items.sum(:yg_cos_fee)}.sum * Jd::Settle::ArticleTax
    commission.round(2)
  end

  # 获取文章写作 已结算佣金 也可以通过流水来计算
  def writing_settled_commission
    commission = self.cps_article_shares.collect{|t| t.cps_promotion_settled_order_items.sum(:yg_cos_fee)}.sum * Jd::Settle::ArticleTax
    commission.round(2)
  end


  # 审核结果发送通知
  def send_notify_to_author
    if status_changed?
      if status == 'passed'
        PushMessage.push_check_to_author(self.author, "文章[#{self.title}],审核通过")
      else
        PushMessage.push_check_to_author(self.author, "文章[#{self.title}],审核拒绝,请进入APP查看原因!")
      end
    end
  end

end
