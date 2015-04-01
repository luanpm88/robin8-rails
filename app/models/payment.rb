class Payment < ActiveRecord::Base
  belongs_to :user_product
  belongs_to :product
  validates :user_product_id, :amount, presence: true

  after_create :set_features

  def user
    self.user_product.user
  end

  def set_features
    product.features.each do |f|
      user_product.user.user_features.create!(
        feature_id: f.id,
        product_id: product.id, #for book keeping
        max_count: product.product_features.where(feature_id: f.id).first.quota,
        available_count: product.product_features.where(feature_id: f.id).first.quota,
        reset_at: product.product_features.where(feature_id: f.id).first.reset_at #use -ve .. i.e total -=1 And add priority i.e which is used before the other
      )
    end
  end

end
