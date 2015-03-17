class AddThumbnailToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :thumbnail, :string
  end
end
