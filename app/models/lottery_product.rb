class LotteryProduct < ActiveRecord::Base

  has_many :activities, class_name: LotteryActivity.to_s, dependent: :destroy
  has_many :posters, class_name: LotteryPoster.to_s, as: :imageable, dependent: :destroy
  has_many :pictures, class_name: LotteryPicture.to_s, as: :imageable, dependent: :destroy

  validates_numericality_of :quantity, greater_than_or_equal_to: 0
  validates_numericality_of :price, greater_than_or_equal_to: 0

  mount_uploader :cover, ImageUploader

  def pub
    self.with_lock do
      return false if self.quantity <= 0

      return false if self.activities.executing.count > 0

      self.activities.create!(
        name: self.name,
        description: self.description,
        total_number: self.price,
        status: "executing"
      )

      self.update(quantity: self.quantity - 1)
    end
  end
end