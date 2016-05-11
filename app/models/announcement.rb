class Announcement < ActiveRecord::Base
  mount_uploader :logo, ImageUploader
  mount_uploader :banner, ImageUploader

  scope :active, -> {where(:display => true)}
  scope :order_by_position, ->{order("position asc")}
end
