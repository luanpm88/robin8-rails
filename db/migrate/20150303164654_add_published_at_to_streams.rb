class AddPublishedAtToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :published_at, :string
  end
end
