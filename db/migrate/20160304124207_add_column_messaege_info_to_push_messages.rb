class AddColumnMessaegeInfoToPushMessages < ActiveRecord::Migration
  def change
    add_column :push_messages, :message_id, :integer
    add_column :push_messages, :item_type, :string
    add_column :push_messages, :item_id, :integer
  end
end
