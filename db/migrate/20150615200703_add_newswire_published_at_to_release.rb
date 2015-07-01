class AddNewswirePublishedAtToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :newswire_published_at, :datetime
  end
end
