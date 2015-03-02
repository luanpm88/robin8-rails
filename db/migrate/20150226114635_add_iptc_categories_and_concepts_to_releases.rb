class AddIptcCategoriesAndConceptsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :iptc_categories, :string
    add_column :releases, :concepts, :text
  end
end
