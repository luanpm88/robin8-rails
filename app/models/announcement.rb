class Announcement < ActiveRecord::Base
  mount_uploader :logo, ImageUploader
  mount_uploader :banner, ImageUploader

  #detail_type %w(invite_friend check_in complete_info url)
  scope :active, -> {where(:display => true)}
  scope :order_by_position, ->{order("position asc")}
end
