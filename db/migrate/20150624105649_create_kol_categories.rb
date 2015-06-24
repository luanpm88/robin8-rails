class CreateKolCategories < ActiveRecord::Migration
  def change
    create_table :kol_categories do |t|
      t.belongs_to :kol, :index => true
      t.string :iptc_category_id
    end
    add_index :kol_categories, :iptc_category_id
  end
end
