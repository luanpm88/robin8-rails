class InitUserAppid < ActiveRecord::Migration
  def change
    User.where("appid is null").each do |user|
      user.init_appid
    end
  end
end
