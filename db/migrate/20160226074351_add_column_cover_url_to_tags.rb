class AddColumnCoverUrlToTags < ActiveRecord::Migration
  def change
    add_column :tags, :cover_url, :string
  end
end
