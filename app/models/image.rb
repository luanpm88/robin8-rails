class Image < ActiveRecord::Base
  belongs_to :referable, :polymorphic => true
  mount :avatar, ImageUploader
end
