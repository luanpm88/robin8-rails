class AddSummariesToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :summaries, :text
  end
end
