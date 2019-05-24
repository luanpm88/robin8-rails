class AddCategoryToKols < ActiveRecord::Migration
  def change
    add_column :kols, :category, :string
  end
end
