class AddOn < ActiveRecord::Base
  validates :name,:price,:presence => true

  before_create :create_slug

  def create_slug
    update_attribute(:slug, name.parameterize)
  end

  def use_by
    validity.present? ? Date.today + validity.to_i.days : nil
  end

end