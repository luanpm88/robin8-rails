class KolAnnouncement < ActiveRecord::Base
  mount_uploader :cover, ImageUploader

  scope :enable, -> {where(:enable => true)}
  scope :order_by_position, ->{order("position asc")}
end
