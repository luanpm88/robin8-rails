class ChangePolymorficTypes < ActiveRecord::Migration
  change_column :addresses, :addressable_type, :string, limit: 20
  change_column :images, :referable_type, :string, limit: 20
  change_column :messages, :item_type, :string, limit: 20
  change_column :messages, :item_id, :integer
  change_column :messages, :receiver_type, :string, limit: 20
  change_column :push_messages, :item_type, :string, limit: 20
  change_column :task_records, :task_type, :string, limit: 20
  change_column :transactions, :account_type, :string, limit: 20
  change_column :transactions, :item_type, :string, limit: 30
  change_column :transactions, :opposite_type, :string, limit: 20
  change_column :users, :invited_by_type, :string, limit: 20
end
