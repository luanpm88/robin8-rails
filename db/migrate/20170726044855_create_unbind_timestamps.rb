class CreateUnbindTimestamps < ActiveRecord::Migration
  def change
    create_table :unbind_timestamps do |t|
      t.integer :kol_id      
      t.string  :provider   
      t.boolean :unbind_count
      t.boolean :bind_count 
      t.date    :unbind_at
      t.timestamps null: false
    end
  end
end
