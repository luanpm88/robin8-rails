class AddOn < ActiveRecord::Base
  validates :name,:price,:presence => true

  def use_by
    validity.present? ? Date.today + validity.to_i.days : nil
  end

end