class CreatePushMessages < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'push_messages'
      drop_table 'push_messages'
    end
    create_table :push_messages do |t|
      t.string :title
      t.string :receiver_type
      t.text :receiver_ids
      t.text :receiver_cids
      t.string :receiver_list
      t.string :template_type
      t.text :template_content
      t.boolean :is_offline, :default => true
      t.integer :offline_expire_time, :default => 1000 * 3600 * 12
      t.string :result
      t.text :result_serial
      t.string :details
      t.string :task_id
      t.string :status

      t.timestamps null: false
    end
  end
end
