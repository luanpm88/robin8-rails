class AddBosonCategories < ActiveRecord::Migration
  def change
    add_column :releases, :boson_categories, :string
  end
end
