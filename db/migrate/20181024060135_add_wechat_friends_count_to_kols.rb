class AddWechatFriendsCountToKols < ActiveRecord::Migration
  def change
    add_column :kols, :wechat_friends_count, :integer, default: 0
  end
end
