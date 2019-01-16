class CreateCreations < ActiveRecord::Migration
  def change
    create_table :creations do |t|
      t.belongs_to :user
      t.string :name
      t.text :description
      t.string :img_url
      t.belongs_to :trademark
      t.datetime :start_at
      t.datetime :end_at
      t.integer :pre_kols_count
      t.integer :kols_count
      t.float :pre_amount, default: 0.0
      t.float :amount, default: 0.0
      t.float :fee_rate, default: 0.0
      t.float :fee, default: 0.0
      t.text :notice
      t.string :status, default: 'pending'
      t.timestamps null: false
    end
  end
end
