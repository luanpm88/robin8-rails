class ProductFeature < ActiveRecord::Base
  belongs_to :feature
  belongs_to :product

  def reset_at
    (validity.present? && product.interval >=30) ? Date.today + validity.to_i.days : nil
  end

  def quota
    count.to_i
  end

end