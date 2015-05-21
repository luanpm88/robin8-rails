class AddNewFieldsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :twitter_ids, :text
    add_column :posts, :facebook_ids, :text
    add_column :posts, :linkedin_ids, :text
  end
end
