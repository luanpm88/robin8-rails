class AddHashtagsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :hashtags, :text
  end
end
