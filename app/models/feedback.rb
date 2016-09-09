class Feedback < ActiveRecord::Base

  belongs_to :kol

  mount_uploader :screenshot, ImageUploader

  has_many :sms_messages, :as => :resource
end
