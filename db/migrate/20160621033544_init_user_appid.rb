class InitUserAppid < ActiveRecord::Migration
  def change
    add_column :users, :appid, :string, :limit => 50
    User.where("appid is null").each do |user|
      user.init_appid
    end
  end
end
