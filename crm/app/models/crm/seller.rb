module Crm
  class Seller < ActiveRecord::Base
    has_secure_password

    mount_uploader :avatar, ImageUploader

    has_many :customers
    has_many :notes
    has_many :users, class_name: 'User'

    has_one :picture, as: :imageable, dependent: :destroy

    def all_campaigns_total_credit
      campaign_ids = []
      User.where(seller_id: id).find_each do |u|
        u.campaigns.each do |c|
          campaign_ids << c.id
        end
      end
      Campaign.where('id in (?)', campaign_ids).agreed.sum(:budget)

    end
  end
end
