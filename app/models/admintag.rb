class Admintag < ActiveRecord::Base

  # Admin tags
  has_and_belongs_to_many :kols

  has_one :admintag_strategy

  scope :select_tag, ->(tag){where(tag: tag)}

  def admin
  	kols.find_by(role: 'admin')
  end


end
