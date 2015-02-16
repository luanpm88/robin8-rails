class RenameColumnsInStreams < ActiveRecord::Migration
  def change
    rename_column :streams, :topics, :topic_ids
    rename_column :streams, :sources, :blog_ids
  end
end
