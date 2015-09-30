class WeiboInvite < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :weibo
end
