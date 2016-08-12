class Image < ActiveRecord::Base
  belongs_to :referable, :polymorphic => true
  mount_uploader :avatar, ImageUploader

  SubTypes = {:cover => 'Kol封面'}
  scope :font_cover, -> {where(:sub_type => 'cover')}
end
