class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :stream_id
      t.string :email
      t.string :phone
      t.boolean :enabled, default: false

      t.timestamps null: false
    end
    
    add_index :alerts, :stream_id
    add_index :alerts, :enabled
  end
end
