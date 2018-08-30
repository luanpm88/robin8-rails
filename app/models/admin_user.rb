class AdminUser < ActiveRecord::Base
  rolify :role_cname => 'AdminRole'
  # rolify
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable


  has_one :e_wallet_account, class_name: "EWallet::Account"

end
