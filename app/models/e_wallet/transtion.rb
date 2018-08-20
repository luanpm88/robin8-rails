class EWallet::Transtion < ActiveRecord::Base
  STATUS = %w(pending successful failed)

  scope :pending, -> {where(:status => 'pending').order('created_at desc')}
  scope :successful, -> {where(:status => 'successful').order('created_at desc')}
  scope :failed, -> {where(:status => 'failed').order('created_at desc')}

  belongs_to :resource, :polymorphic => true
  belongs_to :kol

  def pending?
  	self.status == "pending"
  end

end
