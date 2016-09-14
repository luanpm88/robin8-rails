class UpdateUserNameByMobileNumber < ActiveRecord::Migration
  def change
    User.where(name: nil).map do |u|
      name = u.kol.try(:name).presence
      name = Kol.hide_real_mobile_number(u.kol.try(:mobile_number)) unless name
      name = Kol.hide_real_mobile_number(u.mobile_number) unless name
      u.update(name: name)
    end
  end
end
