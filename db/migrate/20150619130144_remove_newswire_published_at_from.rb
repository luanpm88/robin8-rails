class RemoveNewswirePublishedAtFrom < ActiveRecord::Migration
  def self.up
    remove_column :releases, :newswire_published_at
  end

  def self.down
    add_column :releases, :newswire_published_at, :date
  end
end
