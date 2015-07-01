class AlterColumnReleaseNewswirePublishedAt < ActiveRecord::Migration
  def self.up
    change_table :releases do |t|
      t.change :newswire_published_at, :date
    end
  end
  def self.down
    change_table :releases do |t|
      t.change :newswire_published_at, :datetime
    end
  end
end
