class Role < ActiveRecord::Base
  has_and_belongs_to_many :admin_users, :join_table => :admin_users_roles

  belongs_to :resource,
             :polymorphic => true

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
    when 'campaign_write'
      '活动管理(读写)'
    when 'campaign_invite_read'
      '截图管理(只读)'
    when 'campaign_invite_write'
      '截图管理(读写)'
    end
  end
end
