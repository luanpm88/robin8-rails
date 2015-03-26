class AddOn < ActiveRecord::Base
  validates :name,:price,:presence => true

  def use_by
    validity.present? ? Date.today + validity.days : nil
  end

end