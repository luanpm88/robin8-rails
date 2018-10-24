class WeiboAccountsCity < ActiveRecord::Base
  self.table_name = "weibo_accounts_cities"
  
  belongs_to :weibo_account
  belongs_to :city
end
