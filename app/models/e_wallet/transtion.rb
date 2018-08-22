class EWallet::Transtion < ActiveRecord::Base
  
  STATUS = %w(pending successful failed)
  DIRECTS = %w(income)

  validates_inclusion_of :status, in: STATUS
  validates_inclusion_of :direct, in: DIRECTS

  belongs_to :resource, polymorphic: true
  belongs_to :kol
  belongs_to :campaign

  scope :pending,    -> {where(status: 'pending').order('created_at desc')}
  scope :successful, -> {where(status: 'successful').order('created_at desc')}
  scope :failed,     -> {where(status: 'failed').order('created_at desc')}

  def pending?
  	self.status == "pending"
  end

end
