class Image < ActiveRecord::Base
  belongs_to :referable, :polymorphic => true
  mount_uploader :avatar, ImageUploader
end
