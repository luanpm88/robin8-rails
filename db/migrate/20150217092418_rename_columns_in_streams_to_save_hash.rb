class RenameColumnsInStreamsToSaveHash < ActiveRecord::Migration
  def change
    rename_column :streams, :topic_ids, :topics
    rename_column :streams, :blog_ids, :blogs
  end
end
