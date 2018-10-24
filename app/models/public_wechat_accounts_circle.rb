class PublicWechatAccountsCircle < ActiveRecord::Base
  self.table_name = "public_wechat_accounts_circles"
  
  belongs_to :public_wechat_account
  belongs_to :circle
end
