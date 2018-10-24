class WeiboAccountsCircle < ActiveRecord::Base
  self.table_name = "weibo_accounts_circles"
  
  belongs_to :weibo_accounts
  belongs_to :circle
end
