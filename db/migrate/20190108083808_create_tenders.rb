class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.belongs_to :creation
      t.belongs_to :kol
      t.belongs_to :creation_selected_kol
      t.string :from_terrace
      t.float :price
      t.float :fee, default: 0.0
      t.string :status, default: 'pending'
      t.string :link
      t.string :title
      t.string :image_url
      t.text :description
      t.string :remark
      t.integer :parent_id
      t.boolean :head, default: false
      t.timestamps null: false
    end
  end
end
