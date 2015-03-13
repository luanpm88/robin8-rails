class AddSlugToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :slug, :string
    add_index :releases, :slug
  end
end
