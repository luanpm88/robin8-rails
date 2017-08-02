class CreateBindRecords < ActiveRecord::Migration
  def change
    create_table :bind_records do |t|
      t.integer :kol_id      
      t.string  :provider   
      t.boolean :unbind_count
      t.integer :bind_count 
      t.date    :unbind_at

      t.timestamps null: false
    end
  end
end
