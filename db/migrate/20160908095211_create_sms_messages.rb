class CreateSmsMessages < ActiveRecord::Migration
  def change
    create_table :sms_messages do |t|
      t.string    :phone
      t.string    :content
      t.integer   :receiver_id
      t.string    :receiver_type, limit: 64
      t.integer   :resource_id
      t.string    :resource_type, limit: 64
      t.string    :status, default: :pending, limit: 64
      t.string    :mode, limit: 64
      t.integer   :admin_user_id
      t.string    :remark

      t.timestamps null: false
    end

    add_index(:sms_messages, :status)
    add_index(:sms_messages, :mode)
    add_index(:sms_messages, [ :resource_id, :resource_type ])
    add_index(:sms_messages, [ :receiver_id, :receiver_type ])
  end
end
