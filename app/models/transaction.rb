class Transaction < ActiveRecord::Base
  belongs_to :account, :polymorphic => true

end
