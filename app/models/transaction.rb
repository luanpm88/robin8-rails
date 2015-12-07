class Transaction < ActiveRecord::Base
  belongs_to :account, :polymorphic => true

  def get_subject

  end


end
