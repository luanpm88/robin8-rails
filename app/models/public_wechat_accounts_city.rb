class PublicWechatAccountsCity < ActiveRecord::Base
  self.table_name = "public_wechat_accounts_cities"
  
  belongs_to :public_wechat_account
  belongs_to :city
end
