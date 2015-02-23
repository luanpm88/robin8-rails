class AddShrinkedLinksToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :shrinked_links, :boolean
  end
end
