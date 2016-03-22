class Feedback < ActiveRecord::Base

  belongs_to :kol

  mount_uploader :screenshot, ImageUploader
end
