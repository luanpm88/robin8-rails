class AdminRole < ActiveRecord::Base
  has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_roles

  belongs_to :resource,
             :polymorphic => true
            #  :optional => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify

  def self.chinese_name(name)
    case name
    when 'super_admin'
      '超级管理员(拥有所有权限)'
    when 'campaign_read'
      '活动管理(只读)'
    when 'campaign_update'
      '活动管理(读写)'
    when 'campaign_invite_read'
      '截图管理(只读)'
    when 'campaign_invite_update'
      '截图管理(读写)'
    when 'kol_read'
      'kol管理(只读)'
    when 'kol_update'
      'kol管理(读写)'
    when 'withdraw_read'
      '提现管理(只读)'
    when 'withdraw_update'
      '提现管理(读写)'
    when 'hot_item_read'
      '热门榜单(只读)'
    when 'hot_item_update'
      '热门榜单(读写)'
    when 'kol_announcement_read'
      'APP首页滚动栏(只读)'
    when 'kol_announcement_update'
      'APP首页滚动栏(读写)'
    when 'helper_tag_read'
      'APP帮助文档(只读)'
    when 'helper_tag_update'
      'APP帮助文档(读写)'
    when 'lottery_activity_read'
      'APP一元夺宝(只读)'
    when 'lottery_activity_update'
      'APP一元夺宝(读写)'
    when 'user_read'
      '品牌主管理(只读)'
    when 'user_update'
      '品牌主管理(读写)'
    when 'alipay_order_read'
      '充值管理(只读)'
    when 'alipay_order_update'
      '充值管理(读写)'
    when 'invoice_read'
      '发票管理(只读)'
    when 'invoice_update'
      '发票管理(读写)'
    when 'feedback_read'
      '反馈管理(只读)'
    when 'feedback_update'
      '反馈管理(读写)'
    when 'track_read'
      '追踪链接列表(只读)'
    when 'track_update'
      '追踪链接列表(读写)'
    when 'statistic_data_read'
      '统计报表(只读)'
    when 'statistic_data_update'
      '统计报表(读写)'
    when 'app_upgrade_read'
      'APP管理(只读)'
    when 'app_upgrade_update'
      'APP管理(读写)'
    when 'campaign_check'
      '活动审核'
    when 'cps_article_read'
      'CPS管理(只读)'
    when 'cps_article_update'
      'CPS管理(读写)'
    end
  end
end
