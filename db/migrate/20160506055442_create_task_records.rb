class CreateTaskRecords < ActiveRecord::Migration
  def change
    create_table :task_records do |t|
      t.integer :kol_id
      t.integer :reward_task_id
      t.string :task_type
      t.integer :invitees_id
      t.string :screenshot
      t.string :status, :default => 'pending'

      t.timestamps null: false
    end
  end

  add_index :task_records, :kol_id
  add_index :task_records, :reward_task_id
  add_index :task_records, :status

end
