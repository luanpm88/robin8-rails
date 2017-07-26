class CreateUnbindTimestamps < ActiveRecord::Migration
  def change
    create_table :unbind_timestamps do |t|
      t.integer :kol_id      
      t.string  :provider    
      t.string  :unbind_api 
      t.date    :unbind_at  

      t.timestamps null: false
    end
  end
end
