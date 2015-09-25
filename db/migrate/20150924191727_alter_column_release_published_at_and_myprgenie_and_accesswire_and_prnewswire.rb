class AlterColumnReleasePublishedAtAndMyprgenieAndAccesswireAndPrnewswire < ActiveRecord::Migration
  def self.up
    change_table :releases do |t|
      t.change :published_at, :datetime
      t.change :prnewswire_published_at, :datetime
      t.change :myprgenie_published_at, :datetime
      t.change :accesswire_published_at, :datetime
    end
  end
  def self.down
    change_table :releases do |t|
      t.change :published_at, :date
      t.change :prnewswire_published_at, :date
      t.change :myprgenie_published_at, :date
      t.change :accesswire_published_at, :date
    end
  end
end
