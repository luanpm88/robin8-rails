class IncrementLengthForMessageReceiveIds < ActiveRecord::Migration
  def change
    change_column :messages, :receiver_ids, :longtext, :limit => 165000

    change_column :push_messages, :receiver_ids, :longtext, :limit => 165000
    change_column :push_messages, :receiver_cids, :longtext, :limit => 165000
  end
end
