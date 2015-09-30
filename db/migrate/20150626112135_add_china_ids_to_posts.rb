class AddChinaIdsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :weibo_ids, :text
    add_column :posts, :wechat_ids, :text
  end
end
