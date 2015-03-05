class CreateIptcCategories < ActiveRecord::Migration
  def change
    create_table :iptc_categories, id: false do |t|
      t.string :id, limit: 8
      t.string :label
      t.string :parent, limit: 8
      t.integer :level, limit: 1

      t.timestamps null: false
    end
  end
end
