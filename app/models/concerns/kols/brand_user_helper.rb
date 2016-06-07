module Kols
  module BrandUserHelper
    extend ActiveSupport::Concern
    # 有些用户没有手机号 需要绕过
    def brand_user
      user = User.where(:mobile_number => self.mobile_number).first
      if user and not user.kol_id
        user.update(:kol_id => self.id)
      end
      user
    end

    def find_or_create_brand_user
      user = User.where(:mobile_number => self.mobile_number).first
      if user and not user.kol_id
        user.update(:kol_id => self.id)
      end

      unless user
        user = User.create(:mobile_number => self.mobile_number, :kol_id => self.id)
      end
      user
    end
  end
end