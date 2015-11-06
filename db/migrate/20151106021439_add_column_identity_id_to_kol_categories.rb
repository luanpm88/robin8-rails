class AddColumnIdentityIdToKolCategories < ActiveRecord::Migration
  def change
    add_column :kol_categories, :identity_id, :integer
  end
end
