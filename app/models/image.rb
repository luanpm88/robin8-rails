class Image < ActiveRecord::Base
  belongs_to :referable, :polymorphic => true
  mount_uploader :avatar, ImageUploader

  SubTypes = {:kol_font_cover => 'Kol封面'}
  scope :font_cover, -> {where(:sub_type => 'kol_font_cover')}
end
