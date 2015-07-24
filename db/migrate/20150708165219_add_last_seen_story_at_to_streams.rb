class AddLastSeenStoryAtToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :last_seen_story_at, :datetime
    add_index :streams, :last_seen_story_at
  end
end
