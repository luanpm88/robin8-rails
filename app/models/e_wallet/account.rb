class EWallet::Account < ActiveRecord::Base

  validates_uniqueness_of :token, message: '钱包地址已被占用'

  belongs_to :kol
  belongs_to :admin_user
  
end
