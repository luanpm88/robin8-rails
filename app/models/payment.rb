class Payment < ActiveRecord::Base
  belongs_to :user_product
  belongs_to :product
  validates :user_product_id, :amount, presence: true
  belongs_to :discount

  after_create :set_features,:notify_user

  def notify_user
    UserMailer.payment_confirmation(self.user_product.user, self).deliver if product.is_package?
  end

  def user
    self.user_product.user
  end

  def set_features
    product.features.each do |f|
      product_quota = product.product_features.where(feature_id: f.id).first.quota
      if product.slug == 'smart_release'
        available_count = product_quota
      else
        available_count = product.is_package ? product_quota - user.used_count_by_slug(f.slug) : product_quota
      end

      user_product.user.user_features.create!(
        feature_id: f.id,
        product_id: product.id, #for book keeping
        max_count: product.product_features.where(feature_id: f.id).first.quota,
        available_count: available_count < 0 ? 0 : available_count,
        reset_at: product.product_features.where(feature_id: f.id).first.reset_at #use -ve .. i.e total -=1 And add priority i.e which is used before the other
      )
    end
  end

end
