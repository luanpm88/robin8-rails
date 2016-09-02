module Crm
  class Seller < ActiveRecord::Base
    has_secure_password

    mount_uploader :avatar, ImageUploader

    has_many :customers
    has_many :notes

    has_one :picture, as: :imageable, dependent: :destroy
  end
end
