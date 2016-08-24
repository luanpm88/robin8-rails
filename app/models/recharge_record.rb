class RechargeRecord < ActiveRecord::Base

  belongs_to :receiver, :polymorphic => true
  belongs_to :admin_user
end