class AddColumnFromTypeToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :from_type, :string, :default => 'pc'
  end
end
