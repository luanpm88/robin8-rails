module Kols
  module BrandUserHelper
    extend ActiveSupport::Concern
    def find_or_create_brand_user
      user = User.find_or_initialize_by(kol_id: self.id)

      if user.new_record?
        user.mobile_number  = self.mobile_number if self.mobile_number
        user.email          = self.email         if self.email
        user.name           = self.name          
        user.is_active      = false
      else
        user.is_active = true
      end

      user.save
    end

    def brand_amount
      self.find_or_create_brand_user.amount
    end
  end
end