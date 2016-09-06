class CreateCrmNotes < ActiveRecord::Migration
  def change
    create_table :crm_notes do |t|
      t.string :title
      t.text :content
      t.integer :case_id
      t.integer :seller_id
      t.timestamps null: false
    end
  end
end
