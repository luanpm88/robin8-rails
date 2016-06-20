module Kols
  module BrandUserHelper
    extend ActiveSupport::Concern
    def find_or_create_brand_user
      unless self.mobile_number
        user = User.find_or_create_by(:kol_id => self.id)
        return user
      end

      user = User.where(:mobile_number => self.mobile_number).first
      if user and not user.kol_id
        user.update(:kol_id => self.id)
      end

      unless user
        user = User.create(:mobile_number => self.mobile_number, :kol_id => self.id)
      end
      user
    end

    def brand_amount
      self.find_or_create_brand_user.amount
    end
  end
end