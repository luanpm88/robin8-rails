class AddColumnSubMessageTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sub_message_type, :string
  end
end
